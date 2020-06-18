#include "project.h"
#include "Timer.h"

module projectSinkC

{
	uses 
	{
	/****** INTERFACES *****/

		interface Boot; 
	
		//interfaces for communication
    	interface SplitControl as AMControl;
    	interface AMSend;
    	interface Packet;
    	interface AMPacket;
    	interface Receive;
    	
		//timer interfaces
		interface Timer<TMilli> as TresholdTimer;
		interface Timer<TMilli> as DataTimer;
	
		//other interfaces, if needed
    	//interface PacketAcknowledgements as Ack;
	
		//interface used to perform sensor reading (to get the value from a sensor)
		interface Read<uint16_t>;
  	}

} 
implementation
{


  	message_t packet;
  	bool locked = FALSE;
  	uint16_t data;
  	uint16_t mote_treshold;

  	void sendData();
  	void readData();
  	void getTreshold();
  

	//***************** Boot event ********************//
  	event void Boot.booted()
  	{
		call AMControl.start();	
  	}

	//***************** SplitControl event********************//
  	event void AMControl.startDone(error_t err)
  	{
  		mote_treshold = 33;
  		if(err == SUCCESS)
  		{
  			dbg ("boot", "Booting ... I'm node : %d, Radio started at time: %s \n", TOS_NODE_ID, sim_time_string());
  			if(TOS_NODE_ID ==1){
				call TresholdTimer.startPeriodicAt(0, 1000);
			}
			else{
				mote_treshold = 0;
				call DataTimer.startPeriodicAt(0, 1000);
			}
  		}
  		else
  		{
  			dbgerror("error", "radio didn't start\n");
  			call AMControl.start();
  		}
  
  	}
  
  	event void AMControl.stopDone(error_t err){}


  
  //***************** MilliTimer events ( read a new treshold or a new Data ********************//
  	event void TresholdTimer.fired() 
  	{
	 	dbg_clear("timer", "\n");
		dbg("timer","Treshold timer fired at %s.\n", sim_time_string());
		call Read.read();
	}
  
  	event void DataTimer.fired() 
  	{
	 	dbg_clear("timer", "\n");
		dbg("timer","Data timer fired at %s.\n", sim_time_string());
		call Read.read();
	}
	

  //*********************Send interface ****************//
  	event void AMSend.sendDone(message_t* buf,error_t err)
  	{
  		if( &packet == buf)
  		{   
  			locked = FALSE;
  			if ( err == SUCCESS)
  			{
				dbg("radio_send", "packet sent at time %s \n", sim_time_string());
  			}
			else
			{
				dbgerror("error", "error in sending packet, send the request again\n");

			} 
		} 		
  	}
  	


	//***************************** Receive interface *****************//
  	event message_t* Receive.receive(message_t* buf,void* payload, uint8_t len) 
  	{
  		if(TOS_NODE_ID ==1){
      		Data_msg* mess = (Data_msg*)payload;
			data = mess-> value;
    	  	dbg("error", "sink node received data message with data %hu\n", data);   		
    	}
    	else{
      		Setup_msg* mess = (Setup_msg*)payload;
	  		mote_treshold = mess-> treshold;
	  		mote_treshold = mess -> treshold;
	  		dbg("radio_pack", "Packet with new treshold: %hu \n", mess->treshold);
      		dbg("radio_rec", "A mote node has received a treshold message with treshold %hu\n", mote_treshold);
    	} 
    	return buf;
 
   	}

	
	
	  	
  
	//************************* Read interface **********************//
  	event void Read.readDone(error_t result, uint16_t dataRead) 
  	{
		if(TOS_NODE_ID ==1){
  			Setup_msg* mess = (Setup_msg*)(call Packet.getPayload(&packet, sizeof(Setup_msg)));  
			dbg("treshold","Sink just read new treshold %hu\n",dataRead);  	
			if (mess == NULL) return;
			mess->sender = TOS_NODE_ID;
			mess->treshold = dataRead;

			if(call AMSend.send(AM_BROADCAST_ADDR, &packet,sizeof(Setup_msg)) == SUCCESS)
			{
			   	dbg("radio_send", "Packet passed to lower layer successfully!\n");
			   	dbg("radio_pack","Treshold Packet sent from : %hu, treshold: %hu\n", mess->sender, mess->treshold);
			   	locked = TRUE;
			}
		}
		else{		
			if(dataRead > mote_treshold){
  				Data_msg* mess = (Data_msg*)(call Packet.getPayload(&packet, sizeof(Data_msg)));  
				dbg("data","read value from the sensor %f\n",dataRead);  	
	
				if (mess == NULL) return;
				mess->sender = TOS_NODE_ID;
				mess->value = dataRead;
		
				if(call AMSend.send(AM_BROADCAST_ADDR, &packet,sizeof(Data_msg)) == SUCCESS)
				{
					dbg("radio_send", "Packet passed to lower layer successfully!\n");
			   		dbg("radio_pack","Packet sent from mote: %hu, data: %hu\n", mess->sender, mess->value);
			   		locked = TRUE;
				}
				
	  		}
		}
  	}
  	
  	
  	

}



