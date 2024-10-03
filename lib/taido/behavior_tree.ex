defprotocol Taido.BehaviorTree do
  def tick(tree, state)
  def handle_message(tree, message)
  def terminate(tree)
end
