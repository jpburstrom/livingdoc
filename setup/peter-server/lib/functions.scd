(
divideSensibly: { |self, totalDur, numItems, minSize|
	//Set max size to items * minSize
	//Which gives us a bit of
	var maxSize = totalDur - (minSize * (numItems - 1));
	var temp = numItems.collect({ minSize.rrand(maxSize) });
	var diff = totalDur - temp.sum;
	//Safety net
	var count=1000;
	var index, change;

	if ((minSize * numItems) < totalDur) {
		while { diff != 0 and: { count > 0 } } {
			//Find the most middle index
			index = temp.maxIndex { |x|
				(x - minSize).min(maxSize - x);
			};
			count = count - 1;
			//If too much
			if (diff.isNegative) {
				//Adding
				// "subtracting from sum".postln;
				change = (diff.max((minSize - temp[index]) * 0.5));
			} {
				// "adding to sum".postln;
				change = diff.min((maxSize - temp[index]) * 0.5);
			};
			temp[index] = temp[index] + change;
			diff = totalDur - temp.sum;

		};

	} {
		count = 0;
	};

	if (count <= 0) {
		"Couldn't compute, sorry".warn;
		nil
	} {
		// (1000 - count);
		temp;
	}
},

divideSensibly2: { |self, totalDur, numItems, minSize|

	if (((numItems + 1) * minSize) > totalDur) {
		"Can't divide sensibly with these parameters".warn;
	} {

		var sum = totalDur;
		var bounds = [minSize, sum - (minSize * (numItems-1))];

		numItems.collect { |i|
			var next = i + 1;
			if (next == numItems) {
				sum;
			} {
				var out;
				var rest = numItems - next;
				var restBounds = bounds * rest;
				bounds = [
					max(bounds[0], sum - restBounds[1]),
					min(bounds[1], sum - restBounds[0])
				];
				out = bounds[0].rrand(bounds[1]);
				sum = sum - out;
				out
			}
		};
	}
}
);
