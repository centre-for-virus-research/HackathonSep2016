var statsToolApp = angular.module('statsToolApp', []);


statsToolApp.controller('statsToolCtrl', 
  [ '$scope', '$http',
function ($scope, $http) {

	  $scope.svgWidth = 800;
	  $scope.svgHeight = 800;
	  
	  $scope.svg = d3.select("svg");
	  $scope.contigs = [];
	  
	  $scope.updateData = function() {
		
		d3.selectAll("svg > *").remove();
		
		if(!$scope.xMetric) {
			return;
		}
		if(!$scope.yMetric) {
			return;
		}
		
		var xMetricProperty = $scope.xMetric.property;
		var yMetricProperty = $scope.yMetric.property;
		
		console.log("xMetricProperty: ", xMetricProperty);
		console.log("yMetricProperty: ", yMetricProperty);
		
		var selection = 
		  	$scope.svg
		  	.selectAll("circle")
		  	.data($scope.contigs);
		
	  	selection.enter()
		  	.append("circle")
		  	.attr("cx", function(d) {
		  		return 10+(d[xMetricProperty] * ($scope.svgWidth-20));
		  	})
		  	.attr("cy", function(d) {
		  		return 10+((1.0-d[yMetricProperty]) * ($scope.svgHeight-20));
		  	})
		  	.attr("r", 5)
		  	.style("fill", function(d) {
		  		if(d.isDark) 
		  			{ return "red"; } 
		  		else
		  			{ return "green"; }
		  	});
	  	
	  }
	  
	  console.log("retrieving sequence metrics");
	  $http.get("../../../hackathon2016/sequenceMetrics")
	    .success(function(data, status, headers, config) {
			  console.info('success', data);
			  $scope.sequenceMetrics = data.sequenceMetrics;
			  $scope.xMetric = $scope.sequenceMetrics[0];
			  console.log("xMetric", $scope.xMetric);
			  $scope.yMetric = $scope.sequenceMetrics[1];
			  console.log("yMetric", $scope.yMetric);

	    })
	    .error(function(data, status, headers, config) {
			  console.info('error', data);
	    });

		$scope.$watch( 'currentSample', function(newObj, oldObj) {
			$scope.currentSampleChanged();
			$scope.contigs = [];
			$scope.updateData();
		}, false);

		$scope.$watch( 'currentSequence', function(newObj, oldObj) {
			$scope.contigs = [];
			$scope.updateData();
		}, false);

		$scope.$watch( 'xMetric', function(newObj, oldObj) {
			$scope.updateData();
		}, false);

		$scope.$watch( 'yMetric', function(newObj, oldObj) {
			$scope.updateData();
		}, false);

	  
		  console.log("retrieving samples");
		  $http.get("../../../hackathon2016/samples")
		    .success(function(data, status, headers, config) {
				  console.info('success', data);
				  $scope.samples = data.samples;
				  $scope.currentSample = $scope.samples[0];
				  console.log("samples", $scope.samples);

		    })
		    .error(function(data, status, headers, config) {
				  console.info('error', data);
		    });

	  $scope.currentSampleChanged = function() {
		  $scope.sequences = null;
		  if($scope.currentSample == null)  {
			  return;
		  }
		  console.log("retrieving sequences");
		  $http.post("../../../hackathon2016/sequences", 
				  {sampleId: $scope.currentSample.id})
		    .success(function(data, status, headers, config) {
				  console.info('success', data);
				  $scope.sequences = data.sequences;
				  $scope.currentSequence = $scope.sequences[0];
				  console.log("samples", $scope.samples);

		    })
		    .error(function(data, status, headers, config) {
				  console.info('error', data);
		    });
	  };
	  
	  
	  $scope.getContigs = function() {
		  var requestObj = {
				  sequenceId: $scope.currentSequence.sequenceId
		  };
		  console.log("Updating for request", requestObj);
		  $http.post("../../../hackathon2016/getContigs", requestObj)
		  .success(function(data, status, headers, config) {
			  console.info('success', data);
			  $scope.contigs = data.contigs;
			  $scope.updateData();
		  })
		  .error(function(data, status, headers, config) {
			  console.info('error', data);
		  });
	  }
	  
  } ]);


