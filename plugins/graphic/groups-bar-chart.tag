<groups-bar-chart>
	<p class="text-center">Objetivo de viaticos por grupo, incluyendo máximo y mínimo</p>
	<div id="chart-container">
	</div>
	<style>
		rect.min, 
		rect.max,
		rect.average {
			opacity: 0.3;
			transition: all 0.5s;
		}
		rect.min:hover, 
		rect.max:hover,
		rect.average:hover {
			opacity: 1;
		}
	</style>
	<script>
		this.on('mount', function() {
			if(this.opts.data) {
				this.generateGraph();
			}
		})

		this.on('update', function() {
			if(this.opts.data) {
				this.generateGraph();
			}
		})

		this.generateGraph = function() {
			$('#chart-container').html('');
			const data = this.opts.data;

			const keys = Object.keys(data[0]);
	    
			const tip = d3.tip()
				.attr('class', 'chart-tooltip')
				.html(function(d) {return d.value});

			const margin = {
			    top: 40,
			    right: 80,
			    bottom: 20,
			    left: 80
			  },
			  width = $(window).width(),
			  height = 480,
			  innerWidth = width - margin.left - margin.right,
			  innerHeight = height - margin.top - margin.bottom,
			  svg = d3.select('#chart-container').append('svg').attr('width', width).attr('height', height).attr('class', 'svg-chart'),
			  g = svg.append('g').attr('transform', `translate(${margin.left}, ${margin.top})`);
			    
			svg.call(tip)

			const x0 = d3.scaleBand()
			  .rangeRound([0, innerWidth])
			  .paddingInner(.1);

			const x1 = d3.scaleBand()
			  .padding(.05);

			const y = d3.scaleLinear()
			  .rangeRound([innerHeight, 0]);

			const z = d3.scaleOrdinal()
			  .range(['#aa1e1e', '#3178a7', '#77b3db', '#dddddd']);
			    
			  x0.domain(data.map(function(d,i){ return 'Grupo ' + (i + 1) }));
			  x1.domain(keys).rangeRound([0, x0.bandwidth()]);
			  //y.domain([0, d3.max(data, function(d) { return d3.max(keys, function(key) { return d[key]} ) } )]).nice();
			  y.domain([0, d3.max(data, function(d) { return d.target } )]).nice();
			
			g.append('g')
			  .selectAll('g')
			  .data(data)
			  .enter()
			  .append('g')
			  .attr('transform', function(d,i) {return 'translate(' + x0('Grupo ' + (i + 1)) + ',0)'} )
			  .selectAll('rect')
			  .data(function(d) {
			  	return keys.map(function(key) {return {key: key, value: d[key]}}) 
			  })
			  .enter().append('rect')
			  .attr('class', function(d) { return d.key })
			  .attr('x', function(d) { return x1(d.key) })
			  .attr('y', function(d) { return y(d.value) })
			  .attr('width', x1.bandwidth())
			  .attr('height', d => innerHeight - y(d.value))
			  .attr('fill', d =>  z(d.key))
			  .on('mouseover', tip.show)
			  .on('mouseout', tip.hide)

			g.append('g')
			  .attr('class', 'axis-bottom')
			  .attr('transform', 'translate(0,' + innerHeight + ')')
			  .call(d3.axisBottom(x0));

			g.append('g')
			  .attr('class', 'axis-left')
			  .call(d3.axisLeft(y).ticks(null, 's'))
			  .append('text')
			  .attr('x', 10)
			  .attr('y', y(y.ticks().pop()) + 10)
			  .attr('dy', '0.32em')
			  .attr('fill', '#000')
			  .style('transform', 'rotate(-90deg) translateX(21px)')
			  .attr('font-weight', 'bold')
			  .attr('text-anchor', 'end')
			  .text('Viaticos');

			const legend = g.append('g')
			   .attr('font-family', 'sans-serif')
			   .attr('font-size', 10)
			   .attr('text-anchor', 'end')
			   .selectAll('g')
			   .data(keys.slice())
			   .enter().append('g')
			   .attr('transform', (d, i) => 'translate(0,' + i * 20 + ')');

			legend.append('rect')
			  .attr('x', innerWidth - 19)
			  .attr('width', 10)
			  .attr('height', 10)
			  .attr('fill', z);

			legend.append('text')
			  .attr('x', innerWidth - 32)
			  .attr('y', 6)
			  .attr('dy', '0.32em')
			  .text(function(d) {
			  	var value;
			  	switch(d) {
			  		case 'target':
			  			value = 'Objetivo';
			  			break;
			  		case 'min':
			  			value = 'Mínimo';
			  			break;
			  		case 'max':
			  			value = 'Máximo';
			  			break;
			  		case 'average':
			  			value = 'Promedio';
			  			break;
			  		default:
			  			value = d;
			  	}
			  	return value;
			  });
		}
			
	</script>
</groups-bar-chart>