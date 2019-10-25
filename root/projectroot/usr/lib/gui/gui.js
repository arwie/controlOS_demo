class GraphXY extends Chart {
	constructor() {
		let canvas = document.createElement("canvas");
		canvas.width = canvas.height = 100;
		super(canvas, {
			type: 'line',
			options: {
				scales: {
					xAxes: [{
						type: 'linear',
						position: 'bottom',
						ticks: {
							stepSize: 10,
							suggestedMin: -200,
							suggestedMax:  200
						},
						scaleLabel: {display:false}
					}],
					yAxes: [{
						type: 'linear',
						position: 'left',
						ticks: {
							stepSize: 10,
							suggestedMin: -200,
							suggestedMax:  200
						},
						scaleLabel: {display:false}
					}]
				}
			},
			data: {datasets: [{
				backgroundColor: 'green',
				borderColor:     'green',
				pointRadius:     10,
				data: [{x:0, y:0}]
			}]}
		});
	}
	
	updatePos(x, y) {
		this.data.datasets[0].data[0] = {x:x, y:y};
		this.update();
	}
}


Chart.defaults.global.legend.display		= false;
Chart.defaults.global.animation				= 0;
Chart.defaults.global.tooltips.enabled		= false;
Chart.defaults.global.elements.line.tension	= 0;
