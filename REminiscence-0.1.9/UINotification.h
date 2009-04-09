/*
 *  UINotification.h
 *  Flashback
 *
 *  Created by Stuart Carnie on 4/8/09.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#import "systemstub.h"

/*! Provides a mechanism for guaranteeing the start an end message 
	for a particular UI event is delivered to SystemStub
 */
class UINotification {
public:
	UINotification(SystemStub *stub, SystemStub::tagUINotification msg):_stub(stub), _msg(msg) {
		_stub->uiNotification(_msg, SystemStub::PHASE_START);
	}
	
	~UINotification() {
		_stub->uiNotification(_msg, SystemStub::PHASE_END);
	}
	
private:
	SystemStub						*_stub;
	SystemStub::tagUINotification	_msg;
};