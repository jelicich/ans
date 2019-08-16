<priority-table>
	<ol class="tcp-table">
		<li class="headers">
			<div>Nombre</div>
			<div>Grupo</div>
			<div>Viaticos</div>
			<div>Objetivo</div>
			<div>Diferencia</div>
			<div>Compensacion por lic.</div>
			<div>Diferencia Neta</div>
			<div>Prioridad</div>
		</li>
		<li each="{ tcp in tcpList }">
			<div>{ tcp.nombre }</div>
			<div>{ tcp.grupo }</div>
			<div>{ tcp.viaticos }</div>
			<div>{ tcp.groupTarget }</div> 
			<div>{ tcp.dif }</div>
			<div>{ tcp.planPlus }</div>
			<div>{ tcp.netDif }</div>
			<div>{ tcp.tempIndex }</div>
		</li>
	</ol>
	<style>
	li {
		display: flex;
		padding: 10px;
		border-bottom:1px solid gray;
	}

	li > div {
		flex: 1;
	}
	</style>
	<script>
		var DIF_GROUP = 3;
		var today = new Date();
		var startDate = new Date(2017,11-1,1); // date in which viaticos are being monitored
		var monthDiffViaticos = monthDiff(startDate, today);
		var scaleGroup;

		this.groups = [];

		this.on('mount', function() {
			this.tcpList = opts.tcpList;
			this.createGroupsAndSetDif(this.tcpList);
			this.createScales();
			this.evaluateData(this.tcpList);
			this.update();
			console.log(this.tcpList);
		})

		/**
		 * creates groups and sets min and max viaticos to each group
		 * @param {Object} tcpList - tcp list data from google sheet (processed).
		 */
		this.createGroupsAndSetDif = function(tcpList) {
			var maxViaticos = d3.extent(tcpList, function(d) { return d.viaticos; })[1];
			var minViaticos = d3.extent(tcpList, function(d) { return d.viaticos; })[0];
			var groupsLength = d3.extent(tcpList, function(d) { return d.grupo; })[1];

			var tempTargetViaticos = maxViaticos + DIF_GROUP;
			
			//populate group with dummy data
			for(var i = 0; i < groupsLength; i++) {
				this.groups.push({ 
					target: tempTargetViaticos - DIF_GROUP * i,
					min: maxViaticos,
					max: minViaticos
				});
			}

			tcpList.forEach(function(tcp) {
				//set min max on each group
				var g = tcp.grupo - 1;
				this.groups[g].min = tcp.viaticos < this.groups[g].min ? tcp.viaticos : this.groups[g].min;
				this.groups[g].max = tcp.viaticos > this.groups[g].max ? tcp.viaticos : this.groups[g].max;

				//set dif to tcp
				tcp.dif = this.groups[g].target - tcp.viaticos;
			})
		}


		/**
		 * creates scales used to get indexes 
		 */
		this.createScales = function() {
			//scale used to get group index 
			//used to increase priority % (1 to 10%)
			scaleGroup = d3.scaleLinear();
		    scaleGroup.domain(d3.extent(this.tcpList, function(d) { return d.grupo; }))
			    .range([0.1, 0.01]);
		}

		/**
		 * set extra data to tcp object and sets the temp priority index
		 * @param {Object} tcp - tcp object with row info.
		 */
		this.evaluateData = function(tcpList) {
			tcpList.forEach(function(tcp) {
				//set planPlus (average of viaticos to be added to the real viaticos) 
				var planPlus = 0;
				if(tcp.licenciaplanactivo === 'TRUE') {
					var dailyAverage = getDailyAverage(tcp);
					var planDuration = monthDiff(new Date(tcp.iniciolicenciaplan), today);
					planPlus += dailyAverage * planDuration;
				}

				var hasPreviousPlan = !isNaN(parseInt(tcp.totallicenciasplanes));
				if(hasPreviousPlan) {
					var dailyAverage = getDailyAverage(tcp);
					planPlus += dailyAverage * tcp.totallicenciasplanes;
				}
				
				tcp.planPlus = planPlus;

				tcp.groupTarget = this.groups[tcp.grupo-1].target;

				tcp.netDif = tcp.dif - planPlus;

				tcp.tempIndex = (tcp.dif - planPlus) * (1 + scaleGroup(tcp.grupo));
			})
		}

		/**
		 * get daily viaticos average by tcp and their group
		 * @param {Object} tcp - tcp row object
		 */
		 function getDailyAverage(tcp) {
		 	var g = tcp.grupo - 1;
			var average = (this.groups[g].max + grupos[g].min) / 2;
			var dailyAverage = average / monthDiffViaticos;
			return dailyAverage;
		 }

		/**
		 * get month difference between two dates
		 * @param {Date} d1 - date object
		 * @param {Date} d2 - date object
		 */
		function monthDiff(d1, d2) {
		    var months;
		    months = (d2.getFullYear() - d1.getFullYear()) * 12;
		    months -= d1.getMonth() + 1;
		    months += d2.getMonth();
		    return months <= 0 ? 0 : months;
		}
	</script>
</priority-table>