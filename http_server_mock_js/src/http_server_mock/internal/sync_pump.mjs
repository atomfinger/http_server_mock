// A tiny cooperative scheduler.
//
// On the JS target, Gleam has no true blocking I/O: a "synchronous-looking"
// wait (for example, a fake-sync HTTP client built on a Worker + Atomics,
// see the test suite's integration_test_ffi.mjs) has to spin on the main
// thread rather than truly block it. While it spins, the mock server's own
// transport worker may need to ask the main thread "does this stub match?"
// (see server_ffi.mjs) - and that can only happen if the spin loop itself
// makes room for it, since a busy while-loop starves Node's event loop and
// nothing scheduled via a normal event listener gets a chance to run.
//
// Anything that wants a chance to run during such a spin registers a "pump"
// function here. `pumpAll` is called once per iteration of any wait loop
// built on this module - both the idle scheduling in server_ffi.mjs (for the
// ordinary async case, e.g. a real `fetch` call) and any manual spin-wait
// elsewhere (for the fake-sync test case) share the same registry, so a
// pump never has to know which situation it's being driven from.

const pumps = new Set();

export function registerPump(fn) {
  pumps.add(fn);
  return () => pumps.delete(fn);
}

export function pumpAll() {
  for (const fn of pumps) fn();
}
