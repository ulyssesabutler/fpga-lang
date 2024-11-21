# Functions in ijaboi

The function model
```text
Producer        Module interior           Consumer
         |------------------------------|
data  -> |                              | ->  data
valid -> |                              | -> valid
         |                              |
ready <- |                              | <- ready
         |------------------------------|
```

What values do we need to set?
- `consumer.data`, the output of the module
- `consumer.valid`, we need to tell the consuming module when we provide data for it to read
- `producer.ready`, we need to tell the previous module when it can transmit data to us.

What values do we use?
- `producer.data`, to compute the output
- `producer.valid` and `consumer.ready`, are used to trigger the transfer event.
  - In the case of a 1-to-1 correspondence between the input and the output,
    we can assume the ready and valid signals are simply anded together.