const express = require('express');

const router = express.Router();

// أسعار ZYOCAR بالدينار العراقي.
const PLANS = {
  car: [
    { id: 'normal', name: 'عادي', amount: 5000, currency: 'IQD' },
    { id: 'featured', name: 'مميز', amount: 15000, currency: 'IQD' },
    { id: 'vip', name: 'VIP', amount: 25000, currency: 'IQD' },
  ],
  showroom: {
    id: 'showroom_monthly',
    name: 'اشتراك المعرض',
    amount: 100000,
    currency: 'IQD',
    period: 'monthly',
  },
  parts: {
    id: 'parts_monthly',
    name: 'اشتراك قطع الغيار',
    amount: 15000,
    currency: 'IQD',
    period: 'monthly',
  },
};

router.get('/', (_, res) => {
  res.json(PLANS);
});

module.exports = router;
