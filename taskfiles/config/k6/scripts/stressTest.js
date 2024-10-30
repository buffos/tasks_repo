import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // Key configurations for stress load test in this section (number of users depends on the app)
  stages: [
    { duration: '10m', target: 200 }, // traffic ramp-up from 1 to a higher 200 users over 10 minutes.
    { duration: '30m', target: 200 }, // stay at higher 200 users for 30 minutes
    { duration: '5m', target: 0 }, // ramp-down to 0 users
  ],
};

const baseUrl = 'http://localhost:8080'; // if we are running our app in a different host, we need to change this
const localHost = `http://host.docker.internal:8080`; // if we are running the app on localhost and the k6 in a container, we need to use this to access the app

export default function () {
  // use more complex paths, post, put, delete, etc.
  // organize in groups etc.
  // look at examples for complex examples https://grafana.com/docs/k6/latest/examples/
  const urlRes = http.get(`${baseUrl}/api/v1/some_path`);
  check(urlRes, {
    'is status 200': (r) => r.status === 200,
  });
  sleep(1);
}
