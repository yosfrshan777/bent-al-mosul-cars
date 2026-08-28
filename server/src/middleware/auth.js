const jwt = require('jsonwebtoken');

function auth(req, res, next) {
  const header =
    req.headers.authorization || '';

  if (!header.startsWith('Bearer ')) {
    return res.status(401).json({
      message: 'يجب تسجيل الدخول',
    });
  }

  const token = header.substring(7).trim();

  if (!token) {
    return res.status(401).json({
      message: 'رمز الدخول مفقود',
    });
  }

  try {
    const decoded = jwt.verify(
      token,
      process.env.JWT_SECRET,
    );

    req.user = decoded;

    next();
  } catch (_) {
    return res.status(401).json({
      message: 'جلسة الدخول غير صالحة',
    });
  }
}

function admin(req, res, next) {
  if (
    req.user?.role !== 'admin' &&
    req.user?.role !== 'owner'
  ) {
    return res.status(403).json({
      message: 'ليس لديك صلاحية الإدارة',
    });
  }

  next();
}

module.exports = {
  auth,
  admin,
};
