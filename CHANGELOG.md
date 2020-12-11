## [0.2.1] - New method to create action

Actions can now be defined with a simple function, they should return Strea<Mutation>

```
Stream<Mutation<IncrementMutation>> increment(CounterStore store) async* {
  yield Mutation(store, IncrementMutation());
}
```

Previous ActionRef implementation are still compatible without any changes, but I you suggest to switch to the newer version as it requires less boilerplate and can inherit other actions and you can send a series of mutations

`onError` callback when Action is executed is now changed and it requires to return `List<Mutation>`, these mutations will send to the respective stores and their state will be updated as errors.

## [0.2.0] - Public Release

Initial public release of the package
Includes new Apis and DI tool.

## [0.1.0] - Inital Release

Initial release of the package
