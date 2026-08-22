// A genuinely async HTTP client (no spin-wait, no pumpAll) for
// async_client_test.gleam. This is deliberately the opposite of
// integration_test_ffi.mjs's fake-sync client: the whole point of this file
// is to prove the mock server answers ordinary async callers - the ones the
// cooperative pump exists to NOT be needed for - without any manual
// intervention on the caller's side.

export async function fetchGet(url) {
  const response = await fetch(url);
  const body = await response.text();
  return [response.status, body];
}
