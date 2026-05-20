// k6 load test for Nuveli backend.
//
// Usage:
//   export TEST_TOKEN="<paste real JWT>"
//   k6 run --vus 50 --duration 5m load_test.js
//
// To generate TEST_TOKEN: log in via the app with a test account, then read
// supabase.auth.currentSession.accessToken from Flutter DevTools or copy from
// a network request's Authorization header.

import http from 'k6/http';
import { check, sleep } from 'k6';

const BASE_URL = 'https://nuveli-api.onrender.com';
const TOKEN = __ENV.TEST_TOKEN;

if (!TOKEN) {
  throw new Error('TEST_TOKEN env var is required');
}

export const options = {
  stages: [
    { duration: '30s', target: 10 },   // ramp up
    { duration: '1m',  target: 50 },   // sustained 50 users
    { duration: '30s', target: 100 },  // spike to 100
    { duration: '1m',  target: 100 },  // sustained 100
    { duration: '30s', target: 0 },    // ramp down
  ],
  thresholds: {
    http_req_duration:           ['p(95)<2000'],
    http_req_failed:             ['rate<0.01'],
    'http_req_duration{ep:me}':  ['p(95)<1000'],
    'http_req_duration{ep:summary}': ['p(95)<1500'],
    'http_req_duration{ep:dash}':    ['p(95)<2500'],
  },
};

const authHeaders = {
  Authorization: `Bearer ${TOKEN}`,
  'Content-Type': 'application/json',
};

export default function () {
  // 1) /me — auth dependency stress, minimal DB
  const me = http.get(`${BASE_URL}/me`, {
    headers: authHeaders,
    tags: { ep: 'me' },
  });
  check(me, { 'me=200': (r) => r.status === 200 });

  // 2) /meals/today/summary — DB single-user query
  const summary = http.get(`${BASE_URL}/meals/today/summary`, {
    headers: authHeaders,
    tags: { ep: 'summary' },
  });
  check(summary, { 'summary=200': (r) => r.status === 200 });

  // 3) /analytics/dashboard — heavier aggregation
  const dash = http.get(`${BASE_URL}/analytics/dashboard`, {
    headers: authHeaders,
    tags: { ep: 'dash' },
  });
  check(dash, { 'dash=200': (r) => r.status === 200 });

  // 1s think time between user actions — keeps simulation realistic.
  sleep(1);
}
