import http from 'k6/http';
import { sleep, check } from 'k6';

export const options = {
  vus: 10,
  duration: '30s',
  batch: 15, // The maximum number of simultaneous/parallel connections in total that an http.batch() call in a VU can make.
  discardResponseBodies: true, // Specify if response bodies should be discarded by changing the default value of responseType to none for all HTTP requests
  // iterations: 10, // An integer value, specifying the total number of iterations of the default function to execute in the test run
};

// more info https://grafana.com/docs/k6/latest/using-k6/thresholds/
const threshold = {
  // metrics thresholds
  thresholds: {
    // METRIC : ['threshold expressions', ...] . Expressions include avg, p(90), p(95), p(99), min, max, count
    http_req_failed: ['rate<0.01'], // http errors should be less than 1%
    http_req_duration: ['p(95)<200'], // 95% of requests should be below 200ms
  },
};

const stages = [
  { duration: '30s', target: 10 }, // Ramp up to 10 users
  { duration: '1m', target: 10 }, // Stay at 10 users
  { duration: '30s', target: 0 }, // Ramp down to 0 users
];

// Use tags to group dynamic url requests

// 1. init code

export function setup() {
  // 2. setup code
}

// 3. VU code

export default function () {
  for (let id = 1; id <= 100; id++) {
    http.get(`http://example.com/posts/${id}`, {
      tags: { name: 'PostsItemURL', type: 'API' },
    });
  }
  sleep(1);
}

export function teardown(data) {
  // 4. teardown code
}

function withChecks() {
  const res = http.get('http://test.k6.io/');
  // HTTP response code is a 200
  // verify the response body
  // check for body size
  check(res, {
    'is status 200': (r) => r.status === 200,
    'verify homepage text': (r) =>
      r.body.includes(
        'Collection of simple web-pages suitable for load testing'
      ),
    'body size is 11,105 bytes': (r) => r.body.length == 11105,
  });
}

const scenarios = {
  // scenario documentation here https://grafana.com/docs/k6/latest/using-k6/scenarios/
  example_scenario: {
    // name of the executor to use
    executor: 'shared-iterations',

    // common scenario configuration
    startTime: '10s',
    gracefulStop: '5s',
    env: { EXAMPLEVAR: 'testing' },
    tags: { example_tag: 'testing' },

    // executor-specific configuration
    vus: 10,
    iterations: 200,
    maxDuration: '10s',
  },
  another_scenario: {
    /*...*/
  },
};

/* we have the following executors:
- shared-iterations shares iterations between VUs.
- per-vu-iterations has each VU run the configured iterations.
- constant-VUs sends VUs at a constant number.
- ramping-vus ramps the number of VUs according to your configured stages.
- constant-arrival-rate starts iterations at a constant rate.
- ramping-arrival-rate ramps the iteration rate according to your configured stages.
*/
