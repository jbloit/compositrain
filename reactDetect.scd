/*
Detect reactivision fiducial symbols and map the detected grid to a
sequence of indices the the sequencer can read from.
*/


(

// The number of slots in the sequence
~slotCount = 6;

// The sequence to build. "-1" means no fiducial at the slot.
~seq= (-1!~slotCount);

// a local version of the sequence
~tmpSeq= (-1!~slotCount);

OSCdef(\vision).free;
OSCdef(\vision, {
	| msg, time, addr, port |

	var sessionID, classID, posX, posY;

//	msg.postln;

	// The alive message is sent periodically. We reset the sequence and
	// make the previous one available to the sequencer.
	if (msg[1].asString == "alive", {
		~seq = ~tmpSeq;
		// ~seq.postln;
		~tmpSeq= (-1!~slotCount);
	});

	// all "set" messages are received in between successive "alive" messages.
	// we build the sequence
	if (msg[1].asString == "set", {
		var index;
		classID = msg[3];
		posX = msg[4];
		posY = msg[5];

		index =(posX.linlin(0, 1, 0, ~slotCount).ceil - 1);
		~tmpSeq[index] = classID;
	});


}, '/tuio/2Dobj');

)
