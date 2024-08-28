//
//  openconnect.h
//  connect
//
//  Created by CYTECH on 4/11/18.
//  Copyright © 2018 Tran Viet Anh. All rights reserved.
// == openvpncli.hpp

#ifndef openconnect_h
#define openconnect_h

#include <stdio.h>

#include "base.h"

namespace openconnect {
    namespace ClientAPI{
        class OpenClient: public TunBuilderBase{
        public:
            // Primary VPN client connect method, doesn't return until disconnect.
            // Should be called by a worker thread.  This method will make callbacks
            // to event() and log() functions.  Make sure to call eval_config()
            // and possibly provide_creds() as well before this function.
            int  connect(int argc, char **argv, const char * pass);
        };
    };
}

#endif /* openconnect_h */
