# Respondents can submit as long as the budget has a surplus.
class DefaultSimulator extends Simulator
  canSubmit: ->
    super and @net_balance() >= 0
