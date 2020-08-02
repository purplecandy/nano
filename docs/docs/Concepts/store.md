# Store

## Overview

Stores are somewhat similar to Redux Store or Bloc. They contain the state of the application and the logic to mutate the state. A store can hold any type of value, a single record or a collection.

The major difference in Nano is that the application state is divided into multiple stores depending upon features or domain, this allows us to make our code modular. Stores also only contain the business logic related only to its state mutation and computated value, a store only cares about the end input it doesn't care about How the input values are obtained.

!!! tip "Stores are essentially a part of Presentation Layer"

    Stores are a communication link between your Data Layer and Views. A store receives the mutations and it renders a new state accordingls. It only cares about the data required not **How** you obtained the data.

### Mutation

Mutation are events that are received by the Store and cause mutation of the state.

Every store is registered with specific mutations, only those mutation event can cause change of state.

Mutations are so received sequentially by the store. At a time only one mutation are processed, rest of the mutations are queued. Mutations are queued by the order they arrive to the store.

### Reducer

Reducer are pure functions that contains logic  of mutating the state. Unlike Redux reducer is a part of the Store, every store has it's own reducer. Once a mutation is received it's forwarded to the reducer, where you identify the mutation type and change the state accordingly
