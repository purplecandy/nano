# Dispatcher

## Overview

Dispatcher is a control unit of your application. It provides a mechanism to execute actions and dispatch mutations to the stores. Throughout the application you have a single Dispatcher, it becomes very useful in managing dependencies among actions. 

For example waiting for a set of actions to complete before executing an action. Dispatcher also provides  `onError` and `onDone` callbacks on every action.

!!! warning "For Flux/Redux developers"

    In Nano the Dispatcher doesn't keep the track of stores, you will have to provide them with your actions whereas in Redux/Flux every store registers itself with the dispatcher, which allows your to acess the Store directly from the disptacher.

