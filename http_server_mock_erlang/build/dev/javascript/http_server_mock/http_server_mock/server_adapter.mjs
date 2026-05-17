import * as $dynamic from "../../gleam_stdlib/gleam/dynamic.mjs";
import { CustomType as $CustomType } from "../gleam.mjs";

export class ServerAdapter extends $CustomType {
  constructor(start, stop, add_stub, remove_stub, clear_stubs, get_stubs, get_requests, clear_requests) {
    super();
    this.start = start;
    this.stop = stop;
    this.add_stub = add_stub;
    this.remove_stub = remove_stub;
    this.clear_stubs = clear_stubs;
    this.get_stubs = get_stubs;
    this.get_requests = get_requests;
    this.clear_requests = clear_requests;
  }
}
export const ServerAdapter$ServerAdapter = (start, stop, add_stub, remove_stub, clear_stubs, get_stubs, get_requests, clear_requests) =>
  new ServerAdapter(start,
  stop,
  add_stub,
  remove_stub,
  clear_stubs,
  get_stubs,
  get_requests,
  clear_requests);
export const ServerAdapter$isServerAdapter = (value) =>
  value instanceof ServerAdapter;
export const ServerAdapter$ServerAdapter$start = (value) => value.start;
export const ServerAdapter$ServerAdapter$0 = (value) => value.start;
export const ServerAdapter$ServerAdapter$stop = (value) => value.stop;
export const ServerAdapter$ServerAdapter$1 = (value) => value.stop;
export const ServerAdapter$ServerAdapter$add_stub = (value) => value.add_stub;
export const ServerAdapter$ServerAdapter$2 = (value) => value.add_stub;
export const ServerAdapter$ServerAdapter$remove_stub = (value) =>
  value.remove_stub;
export const ServerAdapter$ServerAdapter$3 = (value) => value.remove_stub;
export const ServerAdapter$ServerAdapter$clear_stubs = (value) =>
  value.clear_stubs;
export const ServerAdapter$ServerAdapter$4 = (value) => value.clear_stubs;
export const ServerAdapter$ServerAdapter$get_stubs = (value) => value.get_stubs;
export const ServerAdapter$ServerAdapter$5 = (value) => value.get_stubs;
export const ServerAdapter$ServerAdapter$get_requests = (value) =>
  value.get_requests;
export const ServerAdapter$ServerAdapter$6 = (value) => value.get_requests;
export const ServerAdapter$ServerAdapter$clear_requests = (value) =>
  value.clear_requests;
export const ServerAdapter$ServerAdapter$7 = (value) => value.clear_requests;
