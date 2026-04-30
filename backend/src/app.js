
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const http = require('http');
const WebSocket = require('ws');

const app = express();
app.use(cors());
app.use(express.json());

const SECRET = 'secret123';
const PORT = process.env.PORT || 3000;

const tasks = [
  { id: '1', title: 'Create reusable UI components', completed: false },
  { id: '2', title: 'Integrate backend APIs', completed: true },
  { id: '3', title: 'Enable realtime sync', completed: false },
];

const clients = new Set();

function broadcast(type, payload) {
  const message = JSON.stringify({ type, payload });
  for (const client of clients) {
    if (client.readyState === WebSocket.OPEN) {
      client.send(message);
    }
  }
}

app.post('/api/auth/login', (req, res) => {
  const { email } = req.body;
  if (!email || typeof email !== 'string') {
    return res.status(400).json({ error: 'Valid email is required.' });
  }

  const token = jwt.sign({ email }, SECRET, { expiresIn: '2h' });
  return res.json({
    token,
    user: {
      email,
      role: 'Engineer',
      memberSince: '2024-01-01',
    },
  });
});

function authMiddleware(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.sendStatus(401);
  }

  const token = authHeader.split(' ').pop();
  try {
    const decoded = jwt.verify(token, SECRET);
    req.user = decoded;
    next();
  } catch (error) {
    return res.sendStatus(403);
  }
}

app.get('/api/user/profile', authMiddleware, (req, res) => {
  return res.json({
    user: {
      email: req.user.email,
      role: 'Engineer',
      memberSince: '2024-01-01',
    },
  });
});

app.get('/api/tasks', authMiddleware, (req, res) => {
  return res.json(tasks);
});

app.post('/api/tasks/update', authMiddleware, (req, res) => {
  const { id, title, completed } = req.body;

  if (id != null) {
    const task = tasks.find((item) => item.id === id);
    if (!task) {
      return res.status(404).json({ error: 'Task not found.' });
    }
    task.completed = completed === true;
    broadcast('task_update', { task });
    return res.json({ success: true, task });
  }

  if (!title || typeof title !== 'string') {
    return res.status(400).json({ error: 'Task title is required.' });
  }

  const newTask = {
    id: String(tasks.length + 1),
    title,
    completed: false,
  };
  tasks.unshift(newTask);
  broadcast('task_created', { task: newTask });
  return res.json({ success: true, task: newTask });
});

const server = http.createServer(app);
const wss = new WebSocket.Server({ server, path: '/ws' });

wss.on('connection', (socket, req) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const token = url.searchParams.get('token');

  if (!token) {
    socket.close(1008, 'Authentication required');
    return;
  }

  try {
    jwt.verify(token, SECRET);
  } catch (error) {
    socket.close(1008, 'Invalid token');
    return;
  }

  clients.add(socket);
  socket.send(JSON.stringify({ type: 'connected', payload: { message: 'Realtime sync ready' } }));

  socket.on('close', () => {
    clients.delete(socket);
  });
});

server.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
  console.log('Realtime websocket listening at ws://localhost:' + PORT + '/ws');
});
