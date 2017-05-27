# ExUnit - Wait for Genserver cast in test

I had a Phoenix ExUnit test of a Genserver where I cast method. I
wanted to evalate the result in the test. With `call` you have feedback
immediatelly, but cast is bit tricky. You need to wait thill PID of
process finish (with `:sys.get_state(pid)`)

Here is an solution example:

```elixir
defmodule ProcessNotification do
  def handle_cast(:process_to_document, notification_id) do
    # .... do some processing

    {:noreply, "state_after_execution"}
  end
end

defmodule ProcessNotificationTest do
  test "process should create document" do
    # ...Repo.get(Notification, 123)
    {:ok, pid} = Genserver.start_link(ProcessNotification, notification.id)

    Genserver.handle_cast(pid, :process_to_document)

    {:ok, state_after_execution} = :sys.get_state(pid)  #this will ensure current process waits till PID finish
    # ...
    assert state_after_execution, "..."
  end
end
```
