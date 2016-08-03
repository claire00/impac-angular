module = angular.module('impac.components.widgets.accounts-expense-weight',[])

module.controller('WidgetAccountsExpenseWeightCtrl', ($scope, $q, ChartFormatterSvc, $translate) ->

  w = $scope.widget

  # Define settings
  # --------------------------------------
  $scope.orgDeferred = $q.defer()
  $scope.timePeriodDeferred = $q.defer()
  $scope.accountBackDeferred = $q.defer()
  $scope.accountFrontDeferred = $q.defer()
  $scope.chartDeferred = $q.defer()

  settingsPromises = [
    $scope.orgDeferred.promise
    $scope.timePeriodDeferred
    $scope.accountBackDeferred
    $scope.accountFrontDeferred
    $scope.chartDeferred.promise
  ]

  $scope.forwardParams = {
    accountingBehaviour: 'pnl'
  }

  # Widget specific methods
  # --------------------------------------
  w.initContext = ->
    $scope.isDataFound = w.content? && !_.isEmpty(w.content.account_list)
    $scope.forwardParams.histParams = w.metadata && w.metadata.hist_parameters
    getComparator()

  $scope.getName = ->
    w.selectedAccount.name if w.selectedAccount?

  getComparator = ->
    switch w.metadata.comparator
      when 'turnover'
        $translate('impac.widget.account_expense_weight.comparator.turnover').then((translation)-> $scope.comparator = translation)
      else
        $translate('impac.widget.account_expense_weight.comparator.total_exp').then((translation)-> $scope.comparator = translation)


  # Chart formating function
  # --------------------------------------
  $scope.drawTrigger = $q.defer()
  w.format = ->
    if $scope.isDataFound && w.content.summary?
      companies = _.map w.content.summary, (s) -> s.company
      ratios = _.map w.content.summary, (s) -> s.ratio
      # Display a line instead of a point when only 1 company
      if companies.length == 1
        companies.push(companies[0])
        ratios.push(ratios[0])

      inputData = {labels: companies, values: ratios}

      options = {
        # scaleOverride: true,
        # scaleSteps: 4,
        # scaleStepWidth: 25,
        # scaleStartValue: 0,
        scales: { yAxes: [
          { ticks: {
            suggestedMin: 0
            suggestedMax: 100
            maxTicksLimit: 5
            }
          }
        ]}
        showXLabels: false
        pointDot: false
        currency: '%'
      }
      chartData = ChartFormatterSvc.lineChart([inputData],options)

      # calls chart.draw()
      $scope.drawTrigger.notify(chartData)


  # Widget is ready: can trigger the "wait for settings to be ready"
  # --------------------------------------
  $scope.widgetDeferred.resolve(settingsPromises)
)

module.directive('widgetAccountsExpenseWeight', ->
  return {
    restrict: 'A',
    controller: 'WidgetAccountsExpenseWeightCtrl'
  }
)
