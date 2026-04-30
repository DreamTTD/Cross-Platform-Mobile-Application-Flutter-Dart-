
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const app = express();

app.use(cors());
app.use(express.json());

const SECRET = "secret123";

app.post('/api/auth/login', (req, res) => {
  const { email } = req.body;
  const token = jwt.sign({ email }, SECRET);
  res.json({ token, user: { email } });
});

function authMiddleware(req, res, next) {
  const auth = req.headers.authorization;
  if (!auth) return res.sendStatus(401);
  try {
    const decoded = jwt.verify(auth.split(" ")[1], SECRET);
    req.user = decoded;
    next();
  } catch {
    res.sendStatus(403);
  }
}

app.get('/api/user/profile', authMiddleware, (req, res) => {
  res.json({ email: req.user.email, role: "Engineer" });
});

app.listen(3000, () => console.log("Server running"));
