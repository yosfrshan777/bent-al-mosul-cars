const express = require('express');

const authRoutes = require('./auth');
const carRoutes = require('./cars');
const adminRoutes = require('./admin');
const paymentRoutes = require('./payment');
const showroomRoutes = require('./showrooms');
const partsRoutes = require('./parts');
const messageRoutes = require('./messages');
const uploadRoutes = require('./upload');
const plansRoutes = require('./plans');
const discountRoutes = require('./discounts');
const aiRoutes = require('./ai');

const router = express.Router();

router.use('/auth', authRoutes);
router.use('/cars', carRoutes);
router.use('/admin', adminRoutes);
router.use('/payment', paymentRoutes);
router.use('/showrooms', showroomRoutes);
router.use('/parts', partsRoutes);
router.use('/messages', messageRoutes);
router.use('/upload', uploadRoutes);
router.use('/plans', plansRoutes);
router.use('/discounts', discountRoutes);
router.use('/ai', aiRoutes);

module.exports = router;
