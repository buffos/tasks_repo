import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // Key configurations for Soak test in this section
  stages: [
    { duration: '5m', target: 100 }, // traffic ramp-up from 1 to 100 users over 5 minutes.
    { duration: '8h', target: 100 }, // stay at 100 users for 8 hours!!!
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
