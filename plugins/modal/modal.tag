<modal>
	<div ref="modal" class="Modal">
		<div class="Modal-header">
			<yield from="header"/>
			<button onclick="{ close }">x</button>
		</div>
		<div class="Modal-body">
			<yield from="body"/>
		</div>

		<div class="Modal-footer">
			<yield from="footer"/>
		</div>
	</div>
	<script>
		var ESC_KEY = 27;
		this.show = function() {
			$('body').addClass('modal-open');
			$(this.refs.modal).addClass('is-visible');
		};

		this.close = function() {
			$('body').removeClass('modal-open')
			$(this.refs.modal).removeClass('is-visible');
		}

		addEvent(document, "keydown", function (e) {
		    e = e || window.event;
		    if(e.which == ESC_KEY) {
		    	this.close();
		    }
		}.bind(this));

		function addEvent(element, eventName, callback) {
		    if (element.addEventListener) {
		        element.addEventListener(eventName, callback, false);
		    } else if (element.attachEvent) {
		        element.attachEvent("on" + eventName, callback);
		    } else {
		        element["on" + eventName] = callback;
		    }
		}
	</script>
</modal>