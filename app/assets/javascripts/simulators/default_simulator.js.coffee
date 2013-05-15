# Respondents can submit as long as the budget has a surplus.
class window.DefaultSimulator extends window.Simulator
  canSubmit: ->
    super and @net_balance() >= 0
