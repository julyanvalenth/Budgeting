const { PrismaClient } = require('@prisma/client');
const jwt = require('jsonwebtoken');
require('dotenv').config();

const prisma = new PrismaClient();
prisma.user.findFirst().then(user => {
  if (!user) { console.log('NO_USER'); return; }
  const secret = process.env.JWT_SECRET || 'fallback-secret';
  const token = jwt.sign({ userId: user.id, email: user.email }, secret, { expiresIn: '7d' });
  console.log('TOKEN=' + token);
  console.log('EMAIL=' + user.email);
}).catch(e => console.log('ERR=' + e.message)).finally(() => prisma.$disconnect());
