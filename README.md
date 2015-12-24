# Onetime
An onetime key-value store for elixir.

## Usage
* Create a store  
```elixir
# Without a name
{:ok, pid} = Onetime.start_link()
# With a name
Onetime.start_link(name: :name)
```
* Register a key-value set  
`Onetime.register(pid_or_name, "key", "value")`  
* Drop the key  
`Onetime.register(pid_or_name, "key")`  
* Pop the value for a given key  
```
# Normally
Onetime.pop(pid_or_name, "key")
# With seconds of validity
Onetime.pop(pid_or_name, "key", secs)
```
* Get the value for a given key and update the key  
`Onetime.get_and_update(pid_or_name, "key", "new_key")`  
* Get the value for a given key  
```
# Normally
Onetime.get(pid_or_name, "key")
# With seconds of validity
Onetime.get(pid_or_name, "key", secs)
```
* Clear old keys and values from store  
`Onetime.clear(pid_or_name, secs)`  

