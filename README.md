# Parallel

The "Hello World" of Elixir: a parallel map function. I expanded it a little for the most important functions used in list processing that can be parallelized. Other than that, this module shall stay small and focussed.

In contrast to other similar solutions out there, I do *not* use a capped worker pool, every computation gets spawned at the same time.

## Installation

Add Parallel to your Mixfile

````Elixir
# mix.exs
def deps do
  [
    {:parallel "~> 0.0"}
  ]
end
````

## Usage

````Elixir

Parallel.map [1, 2, 3], fn(x) -> x + 1 end # => [2, 3, 4]

Parallel.each [1, 2, 3], fn(x) -> IO.puts "#{x}" end # => "1" "2" "3"

Parallel.filter [1, 2, 3], fn(x) -> x == 2 end # => [2]

Parallel.reject [1, 2, 3], fn(x) -> x == 2 end # => [1,3]

Parallel.all? [1, 2, 3], fn(x) -> x == 2 end # => false

Parallel.any? [1, 2, 3], fn(x) -> x == 2 end # => true

````

## LICENCE

MIT.
