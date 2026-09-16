'use strict';

const http = require('http');
const crypto = require('crypto');
const { URL } = require('url');

const args = process.argv.slice(2);
const port = Number(argValue('--port') || 8080);
const origin = argValue('--origin') || 'http://localhost:5555';
const ttlSec = Number(argValue('--ttl') || 900);

function argValue(name) {
  const i = args.indexOf(name);
  return i >= 0 ? args[i + 1] : null;
}

const now = () => new Date().toISOString();

function hashPassword(password) {
  return crypto.createHash('sha256').update(`fly-y:${password}`).digest('hex');
}

function tokenValue() {
  return crypto.randomBytes(24).toString('hex');
}

function publicUser(user) {
  return { id: user.id, username: user.username, displayName: user.displayName, role: user.role };
}

const users = [
  { id: 1, username: 'client', passwordHash: hashPassword('Pass123!'), displayName: 'Анна Клиент', role: 'client' },
  { id: 2, username: 'manager', passwordHash: hashPassword('Pass123!'), displayName: 'Игорь Менеджер', role: 'manager' },
  { id: 3, username: 'admin', passwordHash: hashPassword('Pass123!'), displayName: 'Елена Админ', role: 'admin' },
];

const accessTokens = new Map();
const refreshTokens = new Map();
let currentUser = null;

let next = {
  destination: 9,
  hotel: 16,
  category: 9,
  tour: 23,
  client: 9,
  user: 4,
  booking: 2,
};

const bookings = [
  { id: 1, userId: 1, tourId: 1, tourTitle: 'Солнце Антальи', status: 'active', expiresAt: new Date(Date.now() + 7 * 86400000).toISOString() },
];

const destinations = [
  { id: 1, name: 'Анталья', country: 'Турция', deletedAt: null },
  { id: 2, name: 'Хургада', country: 'Египет', deletedAt: null },
  { id: 3, name: 'Дубай', country: 'ОАЭ', deletedAt: null },
  { id: 4, name: 'Рим', country: 'Италия', deletedAt: null },
  { id: 5, name: 'Шамони', country: 'Франция', deletedAt: null },
  { id: 6, name: 'Пхукет', country: 'Таиланд', deletedAt: null },
  { id: 7, name: 'Санторини', country: 'Греция', deletedAt: null },
  { id: 8, name: 'Барселона', country: 'Испания', deletedAt: null },
];

const categories = [
  { id: 1, name: 'Пляжный', deletedAt: null },
  { id: 2, name: 'Экскурсионный', deletedAt: null },
  { id: 3, name: 'Горнолыжный', deletedAt: null },
  { id: 4, name: 'Круиз', deletedAt: null },
  { id: 5, name: 'Гастрономический', deletedAt: null },
  { id: 6, name: 'Семейный', deletedAt: null },
  { id: 7, name: 'Экстрим', deletedAt: null },
  { id: 8, name: 'Новогодний', deletedAt: null },
];

const hotels = [
  { id: 1, name: 'Rixos Premium', country: 'Турция', city: 'Анталья', stars: 5, deletedAt: null },
  { id: 2, name: 'Marriott Marquis', country: 'ОАЭ', city: 'Дубай', stars: 5, deletedAt: null },
  { id: 3, name: 'Hilton Hurghada', country: 'Египет', city: 'Хургада', stars: 4, deletedAt: null },
  { id: 4, name: 'Hotel Roma Centro', country: 'Италия', city: 'Рим', stars: 4, deletedAt: null },
  { id: 5, name: 'Alpine Lodge', country: 'Франция', city: 'Шамони', stars: 3, deletedAt: null },
  { id: 6, name: 'Phuket Palms', country: 'Таиланд', city: 'Пхукет', stars: 4, deletedAt: null },
  { id: 7, name: 'Santorini View', country: 'Греция', city: 'Фира', stars: 5, deletedAt: null },
  { id: 8, name: 'Barcelona Inn', country: 'Испания', city: 'Барселона', stars: 3, deletedAt: null },
  { id: 9, name: 'Kremlin Palace', country: 'Турция', city: 'Анталья', stars: 5, deletedAt: null },
  { id: 10, name: 'Nile Palace', country: 'Египет', city: 'Каир', stars: 4, deletedAt: null },
  { id: 11, name: 'Lara Beach Resort', country: 'Турция', city: 'Анталья', stars: 4, deletedAt: null },
  { id: 12, name: 'Belek Golf Club', country: 'Турция', city: 'Белек', stars: 5, deletedAt: null },
  { id: 13, name: 'Atlantis The Palm', country: 'ОАЭ', city: 'Дубай', stars: 5, deletedAt: null },
  { id: 14, name: 'Grand Hotel Plaza', country: 'Италия', city: 'Рим', stars: 5, deletedAt: null },
  { id: 15, name: 'Bodrum Blue', country: 'Турция', city: 'Бодрум', stars: 5, deletedAt: null },
];

const tours = [
  t(1, 'Солнце Антальи', 'TY-2024-001', 2024, 7, 1, [1], [1], 40, 12, 89000),
  t(2, 'Дубай огни', 'AE-2024-002', 2024, 5, 3, [2], [2], 30, 8, 112000),
  t(3, 'Красное море', 'EG-2024-003', 2024, 7, 2, [3], [1], 36, 4, 76000),
  t(4, 'Рим классика', 'IT-2024-004', 2024, 6, 4, [4], [2], 24, 10, 134000),
  t(5, 'Альпы Шамони', 'FR-2024-005', 2025, 8, 5, [5], [3], 16, 2, 156000),
  t(6, 'Пхукет лагуна', 'TH-2025-006', 2025, 10, 6, [6], [1, 6], 28, 9, 198000),
  t(7, 'Санторини закат', 'GR-2025-007', 2025, 6, 7, [7], [1, 2], 20, 5, 210000),
  t(8, 'Барселона вкус', 'ES-2025-008', 2025, 5, 8, [8], [5], 22, 11, 128000),
  t(9, 'Белек гольф', 'TY-2025-009', 2025, 7, 1, [12], [1], 18, 6, 167000),
  t(10, 'Каир и Нил', 'EG-2025-010', 2025, 8, 2, [10], [2], 26, 7, 121000),
  t(11, 'Пальма Дубая', 'AE-2025-011', 2025, 6, 3, [13], [1, 6], 14, 0, 245000),
  t(12, 'Новый год в Риме', 'IT-2025-012', 2025, 5, 4, [14], [8], 20, 3, 154000),
  t(13, 'Семейный Пхукет', 'TH-2026-013', 2026, 9, 6, [6], [6], 32, 15, 98000),
  t(14, 'Горные каникулы', 'FR-2026-014', 2026, 7, 5, [5], [3], 12, 1, 174000),
  t(15, 'Круиз Эгейский', 'GR-2026-015', 2026, 8, 7, [7], [4], 40, 20, 201000),
  t(16, 'Гастро Барселона', 'ES-2026-016', 2026, 4, 8, [8], [5], 16, 8, 109000),
  t(17, 'Бодрум лето', 'TY-2026-017', 2026, 7, 1, [15], [1], 30, 14, 117000),
  t(18, 'Хургада all inclusive', 'EG-2026-018', 2026, 7, 2, [3], [1, 6], 40, 18, 99000),
  t(19, 'Дубай weekend', 'AE-2026-019', 2026, 4, 3, [2], [2], 20, 0, 139000),
  t(20, 'Рим для двоих', 'IT-2026-020', 2026, 5, 4, [4], [2], 12, 4, 141000),
  t(21, 'Экстрим Альпы', 'FR-2026-021', 2026, 6, 5, [5], [7], 10, 2, 188000),
  t(22, 'Сиде пляж', 'TY-2026-022', 2026, 8, 1, [11], [1], 34, 16, 89000),
];

const clients = [
  c(1, 'Анна', 'Козлова', 'anna.kozlova@mail.test', '+7 900 111 22 33', 'FY-1001'),
  c(2, 'Игорь', 'Смирнов', 'igor.smirnov@mail.test', '+7 900 222 33 44', 'FY-1002'),
  c(3, 'Мария', 'Петрова', 'maria.petrova@mail.test', '+7 900 333 44 55', 'FY-1003'),
  c(4, 'Олег', 'Иванов', 'oleg.ivanov@mail.test', '+7 900 444 55 66', 'FY-1004'),
  c(5, 'Елена', 'Новикова', 'elena.novikova@mail.test', '+7 900 555 66 77', 'FY-1005'),
  c(6, 'Павел', 'Морозов', 'pavel.morozov@mail.test', '+7 900 666 77 88', 'FY-1006'),
  c(7, 'Юлия', 'Белова', 'yulia.belova@mail.test', '+7 900 777 88 99', 'FY-1007'),
  c(8, 'Дмитрий', 'Орлов', 'dmitry.orlov@mail.test', '+7 900 888 99 00', 'FY-1008'),
];

function t(id, title, code, year, durationDays, destinationId, hotelIds, categoryIds, seatsTotal, seatsAvailable, price) {
  return { id, title, code, year, durationDays, destinationId, hotelIds, categoryIds, seatsTotal, seatsAvailable, price, deletedAt: null };
}

function c(id, firstName, lastName, email, phone, number) {
  return {
    id, firstName, lastName, email, phone, deletedAt: null,
    card: { number, issuedAt: '2024-03-12T00:00:00.000Z', expiresAt: '2027-03-12T00:00:00.000Z', status: 'active' },
  };
}

function byId(list, id) {
  return list.find((item) => item.id === Number(id));
}

function send(res, status, body) {
  const json = JSON.stringify(body);
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8',
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'GET,POST,PUT,PATCH,DELETE,OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    'Access-Control-Max-Age': '86400',
  });
  res.end(json);
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let raw = '';
    req.on('data', (chunk) => { raw += chunk; });
    req.on('end', () => {
      if (!raw) return resolve({});
      try { resolve(JSON.parse(raw)); } catch (e) { reject(e); }
    });
    req.on('error', reject);
  });
}

function paginate(rows, query) {
  const page = Math.max(1, Number(query.page) || 1);
  const size = Math.max(1, Number(query.size) || 10);
  const start = (page - 1) * size;
  return { items: rows.slice(start, start + size), page, size, total: rows.length };
}

function sortRows(rows, query, fields) {
  const [field, dir] = String(query.sort || '').split(',');
  const key = fields.includes(field) ? field : fields[0];
  const mul = dir === 'desc' ? -1 : 1;
  return [...rows].sort((a, b) => {
    const av = a[key];
    const bv = b[key];
    if (typeof av === 'string' && typeof bv === 'string') {
      return av.toLowerCase().localeCompare(bv.toLowerCase(), 'ru') * mul;
    }
    return (av - bv) * mul;
  });
}

function visible(list, query) {
  if (query.includeDeleted === 'true' || query.includeDeleted === '1') {
    return list.filter((item) => item.deletedAt);
  }
  return list.filter((item) => !item.deletedAt);
}

function expandTour(tour) {
  const destination = byId(destinations, tour.destinationId);
  return {
    ...tour,
    destination,
    hotels: tour.hotelIds.map((id) => byId(hotels, id)).filter(Boolean),
    categories: tour.categoryIds.map((id) => byId(categories, id)).filter(Boolean),
  };
}

function countToursBy(pred) {
  return tours.filter(pred).length;
}

function issueTokens(user) {
  const access = tokenValue();
  const refresh = tokenValue();
  accessTokens.set(access, { userId: user.id, exp: Date.now() + ttlSec * 1000 });
  refreshTokens.set(refresh, { userId: user.id, exp: Date.now() + 7 * 86400000 });
  return { accessToken: access, refreshToken: refresh, user: publicUser(user) };
}

function readBearer(req) {
  const header = req.headers.authorization || '';
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match ? match[1] : null;
}

function userByToken(token) {
  const session = accessTokens.get(token);
  if (!session || session.exp < Date.now()) return null;
  return users.find((item) => item.id === session.userId) || null;
}

function forbid(res, message = 'Недостаточно прав для этого действия.') {
  send(res, 403, { message });
}

function denyUnless(res, roles) {
  if (!currentUser) {
    send(res, 401, { message: 'Требуется вход в систему.' });
    return false;
  }
  if (!roles.includes(currentUser.role)) {
    forbid(res);
    return false;
  }
  return true;
}

function weakPassword(password) {
  return typeof password !== 'string' || password.length < 8 || !/\d/.test(password) || !/[^A-Za-z0-9]/.test(password);
}

async function handleAuth(req, res, extra, body) {
  if (req.method === 'POST' && extra === 'login') {
    const user = users.find((item) => item.username === String(body.username || '').trim());
    if (!user || user.passwordHash !== hashPassword(body.password || '')) {
      send(res, 401, { message: 'Неверный логин или пароль.' });
      return;
    }
    send(res, 200, issueTokens(user));
    return;
  }
  if (req.method === 'POST' && extra === 'register') {
    const username = String(body.username || '').trim();
    const displayName = String(body.displayName || '').trim();
    const password = String(body.password || '');
    if (!username || !displayName) {
      send(res, 422, { message: 'Ошибка валидации', errors: { username: 'Заполните логин и имя' } });
      return;
    }
    if (weakPassword(password)) {
      send(res, 422, {
        message: 'Ошибка валидации',
        errors: { password: 'Пароль: от 8 символов, цифра и спецсимвол' },
      });
      return;
    }
    if (users.some((item) => item.username === username)) {
      send(res, 422, { message: 'Ошибка валидации', errors: { username: 'Такой логин уже занят' } });
      return;
    }
    const created = {
      id: next.user++,
      username,
      passwordHash: hashPassword(password),
      displayName,
      role: 'client',
    };
    users.push(created);
    send(res, 201, issueTokens(created));
    return;
  }
  if (req.method === 'POST' && extra === 'refresh') {
    const token = String(body.refreshToken || '');
    const session = refreshTokens.get(token);
    if (!session || session.exp < Date.now()) {
      send(res, 401, { message: 'Сессия истекла. Войдите снова.' });
      return;
    }
    const user = users.find((item) => item.id === session.userId);
    if (!user) {
      send(res, 401, { message: 'Сессия истекла. Войдите снова.' });
      return;
    }
    refreshTokens.delete(token);
    send(res, 200, issueTokens(user));
    return;
  }
  if (req.method === 'GET' && extra === 'me') {
    if (!currentUser) {
      send(res, 401, { message: 'Требуется вход в систему.' });
      return;
    }
    send(res, 200, publicUser(currentUser));
    return;
  }
  send(res, 404, { message: 'Не найден маршрут auth' });
}

async function handleBookings(req, res, { id, extra, body }) {
  if (req.method === 'GET' && extra === 'mine') {
    if (!denyUnless(res, ['client'])) return;
    const items = bookings.filter((item) => item.userId === currentUser.id);
    send(res, 200, { items });
    return;
  }
  if (req.method === 'GET' && extra == null && id == null) {
    if (!denyUnless(res, ['manager'])) return;
    send(res, 200, { items: bookings });
    return;
  }
  if (req.method === 'POST' && extra === 'extend' && id != null) {
    if (!denyUnless(res, ['client'])) return;
    const item = bookings.find((row) => row.id === id);
    if (!item) return send(res, 404, { message: 'Бронь не найдена' });
    if (item.userId !== currentUser.id) return forbid(res, 'Можно продлевать только свою бронь.');
    if (item.status !== 'active') return send(res, 409, { message: 'Бронь уже закрыта.' });
    const days = [1, 7, 14].includes(Number(body.days)) ? Number(body.days) : 7;
    item.expiresAt = new Date(new Date(item.expiresAt).getTime() + days * 86400000).toISOString();
    send(res, 200, item);
    return;
  }
  if (req.method === 'POST' && extra === 'close' && id != null) {
    if (!denyUnless(res, ['manager'])) return;
    const item = bookings.find((row) => row.id === id);
    if (!item) return send(res, 404, { message: 'Бронь не найдена' });
    item.status = 'closed';
    send(res, 200, item);
    return;
  }
  if (req.method === 'POST' && extra === 'reopen' && id != null) {
    if (!denyUnless(res, ['manager'])) return;
    const item = bookings.find((row) => row.id === id);
    if (!item) return send(res, 404, { message: 'Бронь не найдена' });
    item.status = 'active';
    send(res, 200, item);
    return;
  }
  send(res, 403, { message: 'Недостаточно прав для этого действия.' });
}

async function handleUsers(req, res, { id, body }) {
  if (!denyUnless(res, ['admin'])) return;
  if (req.method === 'GET' && id == null) {
    send(res, 200, { items: users.map(publicUser) });
    return;
  }
  if (req.method === 'PUT' && id != null) {
    const item = users.find((row) => row.id === id);
    if (!item) return send(res, 404, { message: 'Пользователь не найден' });
    if (['client', 'manager', 'admin'].includes(body.role)) item.role = body.role;
    send(res, 200, publicUser(item));
    return;
  }
  send(res, 404, { message: 'Не найден маршрут пользователей' });
}

async function handle(req, res) {
  const url = new URL(req.url, `http://localhost:${port}`);
  if (req.method === 'OPTIONS') {
    send(res, 204, {});
    return;
  }

  const delay = Number(url.searchParams.get('__delay') || 0);
  if (delay > 0) await new Promise((r) => setTimeout(r, delay));
  const fail = url.searchParams.get('__fail');
  if (fail) {
    send(res, Number(fail) || 500, { message: 'Принудительная ошибка сервера' });
    return;
  }

  const path = url.pathname.replace(/\/+$/, '') || '/';
  const query = Object.fromEntries(url.searchParams.entries());
  const parts = path.replace(/^\/api\/?/, '/').split('/').filter(Boolean);

  if (path === '/api/__health' || path === '/__health') {
    send(res, 200, { ok: true, service: 'fly-y-mock' });
    return;
  }

  let body = {};
  if (req.method !== 'GET') {
    try { body = await readBody(req); } catch (_) {
      send(res, 400, { message: 'Некорректный JSON' });
      return;
    }
  }

  const resource = parts[0];
  const id = /^\d+$/.test(parts[1] || '') ? Number(parts[1]) : null;
  const extra = parts[1] === 'bulk-delete' ? 'bulk-delete' : (parts[1] && !/^\d+$/.test(parts[1]) ? parts[1] : parts[2]);

  currentUser = userByToken(readBearer(req));

  try {
    if (resource === 'auth') {
      if (extra === 'me') {
        if (!currentUser) {
          send(res, 401, { message: 'Требуется вход в систему.' });
          return;
        }
      }
      await handleAuth(req, res, extra, body);
      return;
    }

    if (!currentUser) {
      send(res, 401, { message: 'Требуется вход в систему.' });
      return;
    }

    if (resource === 'bookings') {
      await handleBookings(req, res, { id, extra, body });
      return;
    }
    if (resource === 'users') {
      await handleUsers(req, res, { id, body });
      return;
    }
    if (resource === 'stats') {
      if (!denyUnless(res, ['admin'])) return;
      send(res, 200, {
        users: users.length,
        tours: tours.length,
        hotels: hotels.length,
        clients: clients.length,
        bookings: bookings.length,
      });
      return;
    }
    if (resource === 'tours') {
      await crudTours(req, res, { id, extra, query, body });
      return;
    }
    if (resource === 'hotels') {
      await crudSimple(req, res, hotels, 'hotel', {
        id, extra, query, body,
        search: (item, needle) => item.name.toLowerCase().includes(needle) || item.city.toLowerCase().includes(needle),
        fields: ['name', 'country', 'city', 'stars'],
        create: (b) => ({ id: next.hotel++, name: b.name, country: b.country, city: b.city, stars: Number(b.stars) || 3, deletedAt: null }),
        filter: (rows) => {
          let r = rows;
          if (query.country) r = r.filter((h) => h.country === query.country);
          if (query.stars) r = r.filter((h) => h.stars === Number(query.stars));
          return r;
        },
        linked: (hid) => countToursBy((t) => t.hotelIds.includes(hid)),
      });
      return;
    }
    if (resource === 'destinations') {
      await crudSimple(req, res, destinations, 'destination', {
        id, extra, query, body,
        search: (item, needle) => item.name.toLowerCase().includes(needle) || item.country.toLowerCase().includes(needle),
        fields: ['name', 'country'],
        create: (b) => ({ id: next.destination++, name: b.name, country: b.country, deletedAt: null }),
        filter: (rows) => query.country ? rows.filter((d) => d.country === query.country) : rows,
        linked: (did) => countToursBy((t) => t.destinationId === did),
      });
      return;
    }
    if (resource === 'categories') {
      await crudSimple(req, res, categories, 'category', {
        id, extra, query, body,
        search: (item, needle) => item.name.toLowerCase().includes(needle),
        fields: ['name'],
        create: (b) => ({ id: next.category++, name: b.name, deletedAt: null }),
        filter: (rows) => rows,
        linked: (cid) => countToursBy((t) => t.categoryIds.includes(cid)),
      });
      return;
    }
    if (resource === 'clients') {
      await crudClients(req, res, { id, extra, query, body });
      return;
    }
    send(res, 404, { message: 'Не найден маршрут' });
  } catch (e) {
    send(res, 500, { message: String(e) });
  }
}

async function crudTours(req, res, { id, extra, query, body }) {
  if (req.method === 'GET' && id == null) {
    let rows = visible(tours, query);
    const needle = (query.search || '').toLowerCase();
    if (needle) {
      rows = rows.filter((item) => item.title.toLowerCase().includes(needle) || item.code.toLowerCase().includes(needle));
    }
    if (query.destinationId) rows = rows.filter((item) => item.destinationId === Number(query.destinationId));
    if (query.categoryId) rows = rows.filter((item) => item.categoryIds.includes(Number(query.categoryId)));
    if (query.hotelId) rows = rows.filter((item) => item.hotelIds.includes(Number(query.hotelId)));
    if (query.yearFrom) rows = rows.filter((item) => item.year >= Number(query.yearFrom));
    if (query.yearTo) rows = rows.filter((item) => item.year <= Number(query.yearTo));
    rows = sortRows(rows, query, ['title', 'code', 'year', 'durationDays', 'price']);
    const page = paginate(rows, query);
    send(res, 200, { ...page, items: page.items.map(expandTour) });
    return;
  }
  if (req.method === 'GET' && id != null) {
    const item = byId(tours, id);
    if (!item) return send(res, 404, { message: 'Тур не найден' });
    send(res, 200, expandTour(item));
    return;
  }
  if (req.method === 'POST' && extra === 'book' && id != null) {
    if (!denyUnless(res, ['client', 'manager'])) return;
    const item = byId(tours, id);
    if (!item) return send(res, 404, { message: 'Тур не найден' });
    if (item.seatsAvailable <= 0) {
      return send(res, 409, { message: 'Нет свободных мест на этот тур.' });
    }
    item.seatsAvailable -= 1;
    const booking = {
      id: next.booking++,
      userId: currentUser.id,
      tourId: item.id,
      tourTitle: item.title,
      status: 'active',
      expiresAt: new Date(Date.now() + 7 * 86400000).toISOString(),
    };
    bookings.push(booking);
    send(res, 200, { ...expandTour(item), booking });
    return;
  }
  if (req.method === 'POST' && extra === 'restore' && id != null) {
    if (!denyUnless(res, ['admin'])) return;
    const item = byId(tours, id);
    if (!item) return send(res, 404, { message: 'Тур не найден' });
    item.deletedAt = null;
    send(res, 200, expandTour(item));
    return;
  }
  if (req.method === 'POST' && id == null && extra === undefined) {
    if (!denyUnless(res, ['manager'])) return;
    const code = String(body.code || '').trim().toUpperCase();
    if (tours.some((item) => item.code.toLowerCase() === code.toLowerCase() && !item.deletedAt)) {
      return send(res, 422, { message: 'Ошибка валидации', errors: { code: 'Код тура уже занят' } });
    }
    const created = {
      id: next.tour++,
      title: body.title,
      code,
      year: Number(body.year),
      durationDays: Number(body.durationDays),
      destinationId: Number(body.destinationId),
      hotelIds: body.hotelIds || [],
      categoryIds: body.categoryIds || [],
      seatsTotal: Number(body.seatsTotal),
      seatsAvailable: Number(body.seatsAvailable),
      price: Number(body.price),
      deletedAt: null,
    };
    tours.push(created);
    send(res, 201, expandTour(created));
    return;
  }
  if (req.method === 'POST' && extra === 'bulk-delete') {
    if (!denyUnless(res, ['manager'])) return;
    const ids = body.ids || [];
    let deleted = 0;
    for (const tid of ids) {
      const item = byId(tours, tid);
      if (item && !item.deletedAt) { item.deletedAt = now(); deleted += 1; }
    }
    send(res, 200, { deleted });
    return;
  }
  if (req.method === 'PUT' && id != null) {
    if (!denyUnless(res, ['manager'])) return;
    const item = byId(tours, id);
    if (!item) return send(res, 404, { message: 'Тур не найден' });
    const code = String(body.code || item.code).trim().toUpperCase();
    if (tours.some((row) => row.id !== item.id && row.code.toLowerCase() === code.toLowerCase() && !row.deletedAt)) {
      return send(res, 422, { message: 'Ошибка валидации', errors: { code: 'Код тура уже занят' } });
    }
    Object.assign(item, {
      title: body.title ?? item.title,
      code,
      year: body.year ?? item.year,
      durationDays: body.durationDays ?? item.durationDays,
      destinationId: body.destinationId ?? item.destinationId,
      hotelIds: body.hotelIds ?? item.hotelIds,
      categoryIds: body.categoryIds ?? item.categoryIds,
      seatsTotal: body.seatsTotal ?? item.seatsTotal,
      seatsAvailable: body.seatsAvailable ?? item.seatsAvailable,
      price: body.price ?? item.price,
    });
    send(res, 200, expandTour(item));
    return;
  }
  if (req.method === 'DELETE' && id != null) {
    const item = byId(tours, id);
    if (!item) return send(res, 404, { message: 'Тур не найден' });
    if (query.hard === 'true' || query.hard === '1') {
      if (!denyUnless(res, ['admin'])) return;
      const i = tours.findIndex((row) => row.id === item.id);
      tours.splice(i, 1);
      send(res, 200, { ok: true });
      return;
    }
    if (!denyUnless(res, ['manager'])) return;
    item.deletedAt = now();
    send(res, 200, expandTour(item));
    return;
  }
  send(res, 404, { message: 'Не найден маршрут туров' });
}

async function crudSimple(req, res, list, keyName, cfg) {
  const { id, extra, query, body } = cfg;
  if (req.method === 'POST' && extra === 'bulk-delete') {
    if (!denyUnless(res, ['manager'])) return;
    const ids = body.ids || [];
    let deleted = 0;
    for (const tid of ids) {
      const item = byId(list, tid);
      if (item && !item.deletedAt) { item.deletedAt = now(); deleted += 1; }
    }
    send(res, 200, { deleted });
    return;
  }
  if (req.method === 'GET' && id == null) {
    let rows = visible(list, query);
    const needle = (query.search || '').toLowerCase();
    if (needle) rows = rows.filter((item) => cfg.search(item, needle));
    rows = cfg.filter(rows);
    rows = sortRows(rows, query, cfg.fields);
    send(res, 200, paginate(rows, query));
    return;
  }
  if (req.method === 'GET' && id != null) {
    const item = byId(list, id);
    if (!item) return send(res, 404, { message: 'Не найдено' });
    send(res, 200, item);
    return;
  }
  if (req.method === 'POST' && extra === 'restore' && id != null) {
    if (!denyUnless(res, ['admin'])) return;
    const item = byId(list, id);
    if (!item) return send(res, 404, { message: 'Не найдено' });
    item.deletedAt = null;
    send(res, 200, item);
    return;
  }
  if (req.method === 'POST' && id == null) {
    if (!denyUnless(res, ['manager'])) return;
    const created = cfg.create(body);
    list.push(created);
    send(res, 201, created);
    return;
  }
  if (req.method === 'PUT' && id != null) {
    if (!denyUnless(res, ['manager'])) return;
    const item = byId(list, id);
    if (!item) return send(res, 404, { message: 'Не найдено' });
    const created = cfg.create({ ...item, ...body });
    created.id = item.id;
    created.deletedAt = item.deletedAt;
    Object.assign(item, created);
    send(res, 200, item);
    return;
  }
  if (req.method === 'DELETE' && id != null) {
    const item = byId(list, id);
    if (!item) return send(res, 404, { message: 'Не найдено' });
    if (query.hard === 'true' || query.hard === '1') {
      if (!denyUnless(res, ['admin'])) return;
      const linked = cfg.linked(item.id);
      if (linked > 0) {
        return send(res, 409, { message: `Нельзя удалить: есть ${linked} связанных тур(ов).` });
      }
      const i = list.findIndex((row) => row.id === item.id);
      list.splice(i, 1);
      send(res, 200, { ok: true });
      return;
    }
    if (!denyUnless(res, ['manager'])) return;
    item.deletedAt = now();
    send(res, 200, item);
    return;
  }
  send(res, 404, { message: 'Не найден маршрут' });
}

async function crudClients(req, res, { id, extra, query, body }) {
  const hard = query.hard === 'true' || query.hard === '1';
  if (extra === 'restore' || (req.method === 'DELETE' && hard)) {
    if (!denyUnless(res, ['admin'])) return;
  } else if (!denyUnless(res, ['manager'])) return;
  if (req.method === 'POST' && extra === 'bulk-delete') {
    const ids = body.ids || [];
    let deleted = 0;
    for (const tid of ids) {
      const item = byId(clients, tid);
      if (item && !item.deletedAt) { item.deletedAt = now(); deleted += 1; }
    }
    send(res, 200, { deleted });
    return;
  }
  if (req.method === 'GET' && id == null) {
    let rows = visible(clients, query);
    const needle = (query.search || '').toLowerCase();
    if (needle) {
      rows = rows.filter((item) =>
        `${item.lastName} ${item.firstName}`.toLowerCase().includes(needle) ||
        item.email.toLowerCase().includes(needle),
      );
    }
    if (query.status) rows = rows.filter((item) => item.card.status === query.status);
    rows = sortRows(rows, query, ['lastName', 'firstName', 'email']);
    send(res, 200, paginate(rows, query));
    return;
  }
  if (req.method === 'GET' && id != null) {
    const item = byId(clients, id);
    if (!item) return send(res, 404, { message: 'Клиент не найден' });
    send(res, 200, item);
    return;
  }
  if (req.method === 'POST' && extra === 'restore' && id != null) {
    const item = byId(clients, id);
    if (!item) return send(res, 404, { message: 'Клиент не найден' });
    item.deletedAt = null;
    send(res, 200, item);
    return;
  }
  if (req.method === 'POST' && id == null) {
    const email = String(body.email || '').trim().toLowerCase();
    if (clients.some((item) => item.email === email && !item.deletedAt)) {
      return send(res, 422, { message: 'Ошибка валидации', errors: { email: 'Такая почта уже зарегистрирована' } });
    }
    const created = {
      id: next.client++,
      firstName: body.firstName,
      lastName: body.lastName,
      email,
      phone: body.phone,
      card: body.card || { number: 'FY-NEW', issuedAt: now(), expiresAt: null, status: 'active' },
      deletedAt: null,
    };
    clients.push(created);
    send(res, 201, created);
    return;
  }
  if (req.method === 'PUT' && id != null) {
    const item = byId(clients, id);
    if (!item) return send(res, 404, { message: 'Клиент не найден' });
    const email = String(body.email || item.email).trim().toLowerCase();
    if (clients.some((row) => row.id !== item.id && row.email === email && !row.deletedAt)) {
      return send(res, 422, { message: 'Ошибка валидации', errors: { email: 'Такая почта уже зарегистрирована' } });
    }
    Object.assign(item, {
      firstName: body.firstName ?? item.firstName,
      lastName: body.lastName ?? item.lastName,
      email,
      phone: body.phone ?? item.phone,
      card: body.card ?? item.card,
    });
    send(res, 200, item);
    return;
  }
  if (req.method === 'DELETE' && id != null) {
    const item = byId(clients, id);
    if (!item) return send(res, 404, { message: 'Клиент не найден' });
    if (query.hard === 'true' || query.hard === '1') {
      const i = clients.findIndex((row) => row.id === item.id);
      clients.splice(i, 1);
      send(res, 200, { ok: true });
      return;
    }
    item.deletedAt = now();
    send(res, 200, item);
    return;
  }
  send(res, 404, { message: 'Не найден маршрут клиентов' });
}

http.createServer((req, res) => {
  handle(req, res);
}).listen(port, () => {
  console.log(`Fly-Y mock API http://localhost:${port}/api  CORS origin=${origin}  TTL=${ttlSec}s`);
  console.log('Вход: client/Pass123!  manager/Pass123!  admin/Pass123!');
});
