var statsToolApp = angular.module('statsToolApp', ['ui.bootstrap','dialogs.main']);


statsToolApp.controller('statsToolCtrl', 
  [ '$scope', '$http', 'dialogs',
function ($scope, $http, dialogs) {

	  $scope.svgWidth = 550;
	  $scope.svgHeight = 550;
	  
	  $scope.svg = d3.select("svg");
	  $scope.contigs = [];
	  
	  
	  $scope.cX = function(d) {
			var xMetricProperty = $scope.xMetric.property;
	  		return 10+(d[xMetricProperty] * ($scope.svgWidth-20));
	  	};
	  $scope.cY = function(d) {
			var yMetricProperty = $scope.yMetric.property;
	  		return 10+((1.0-d[yMetricProperty]) * ($scope.svgHeight-20));
	  	};

	  $scope.selectContig = function(d) {
	  		console.log("Selected contig ID:", d.contigId);
	  		$scope.selectedContig = d;
	  		$scope.selectedCircle
		  	.attr("cx", $scope.cX(d))
		  	.attr("cy", $scope.cY(d));
	  		$scope.getContigDetails(d.contigId);
	  };
	  
	  $scope.updateData = function() {
		
		d3.selectAll("svg > *").remove();
		
		if(!$scope.xMetric) {
			return;
		}
		if(!$scope.yMetric) {
			return;
		}
		
		d3.select("svg")
		.append("rect")
		.attr("width", $scope.svgWidth)
		.attr("height", $scope.svgHeight)
		.style("stroke", "black")
		.style("fill", "white");
		
		
		var darkFill = function(d) {return d.isDark ? "#91e6e9" : "#e99491"};
		
		var selection = 
		  	$scope.svg
		  	.selectAll("circle")
		  	.data($scope.contigs);
		
	  	selection.enter()
		  	.append("circle")
		  	.attr("cx", $scope.cX)
		  	.attr("cy", $scope.cY)
		  	.attr("r", 5)
		  	.style("fill", darkFill)
		  	.style("stroke", "black")
		  	.on("mouseover", function(){d3.select(this).style("fill", "black");})
		  	.on("mouseout", function(){d3.select(this).style("fill", darkFill);})
		  	.on("click", $scope.selectContig)
        ;
	  	
	  	$scope.selectedCircle = d3.select("svg")
	  	.append("circle")
	  	.attr("cx", -200)
	  	.attr("cy", -200)
	  	.attr("r", 10)
	  	.style("fill", "none")
	  	.style("stroke", "black")
	  	.style("stroke-width", "3")

	  	if($scope.selectedContig) {
		  	$scope.selectContig($scope.selectedContig);
	  	}

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
			$scope.contigDetails = null;
			$scope.selectedContig = null;
			$scope.updateData();
		}, false);

		$scope.$watch( 'currentSequence', function(newObj, oldObj) {
			$scope.contigs = [];
			$scope.contigDetails = null;
			$scope.selectedContig = null;
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
				  {sampleId: $scope.currentSample.ID})
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
				  sequenceId: $scope.currentSequence.ID
		  };
		  console.log("Retrieving contigs", requestObj);
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

	  
	  $scope.getContigDetails = function(contigId) {
		  var requestObj = {
				  contigId: contigId,
				  xMetric: $scope.xMetric.property,
				  yMetric: $scope.yMetric.property
		  };
		  console.log("Retrieving contig details", requestObj);
		  $http.post("../../../hackathon2016/getContigDetails", requestObj)
		  .success(function(data, status, headers, config) {
			  console.info('success', data);
			  $scope.contigDetails = data;
		  })
		  .error(function(data, status, headers, config) {
			  console.info('error', data);
		  });
	  }

	  $scope.showRelatedDark = function(knownDarkQueryId, otherContigId) {
		  var requestObj = {
				  "knownDarkQueryId": knownDarkQueryId,
				  "otherContigId": otherContigId
		  };
		  console.log("Retrieving knownDark details", requestObj);
		  $http.post("../../../hackathon2016/getKnownDarkDetails", requestObj)
		  .success(function(data, status, headers, config) {
			  console.info('success', data);
			  // pop up dialog
	    		var dlg = dialogs.create("dialogs/displayKnownDark.html",
	    				"displayKnownDarkCtrl", 
	    				data, {});
	    		dlg.result.then(function() {
	    			// completion handler
	    		}, function() {
	    		    // Error handler
	    		}).finally(function() {
	    		    // Finally handler
	    		});
		  })
		  .error(function(data, status, headers, config) {
			  console.info('error', data);
		  });

		  
	  }

	  
	  $scope.showSequencingRunDetails = function() {
			  // pop up dialog
	    		var dlg = dialogs.create("dialogs/displaySequencingRunDetails.html",
	    				"displaySequencingRunDetailsCtrl", 
	    				{
	    					sample: $scope.currentSample,
	    					sequence: $scope.currentSequence
	    				}, {});
	    		dlg.result.then(function() {
	    			// completion handler
	    		}, function() {
	    		    // Error handler
	    		}).finally(function() {
	    		    // Finally handler
	    		});
		  
	  }

	  
	  
	  
  } ]).controller('displayKnownDarkCtrl',function($scope,$modalInstance,data){
		$scope.data = data;
		
		$scope.close = function(){
			$modalInstance.close($scope.data);
		}; 

	}).controller('displaySequencingRunDetailsCtrl',function($scope,$modalInstance,data){
		$scope.data = data;
		
		$scope.close = function(){
			$modalInstance.close($scope.data);
		}; 

	});

