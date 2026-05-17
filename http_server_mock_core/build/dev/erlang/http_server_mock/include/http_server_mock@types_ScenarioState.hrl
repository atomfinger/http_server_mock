-record(scenario_state, {
    name :: binary(),
    required_state :: gleam@option:option(binary()),
    new_state :: gleam@option:option(binary())
}).
