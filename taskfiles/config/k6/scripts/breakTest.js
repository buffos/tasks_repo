import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  // Key configurations for breakpoint in this section
  executor: 'ramping-arrival-rate', //Assure load increase if the system slows
  stages: [
    { duration: '2h', target: 20000 }, // just slowly ramp-up to a HUGE load
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
