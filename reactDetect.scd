

(
OSCdef(\vision).free;
OSCdef(\vision, {
	| msg, time, addr, port |

	var sessionID, classID, posX, posY;

	// msg.postln;


	classID = msg[3];
	posX = msg[4];
	posY = msg[5];

	if (classID==0,
		{postf(" ID %  -- x % y % \n", classID, posX, posY);} , {});


}, '/tuio/2Dobj');

)
