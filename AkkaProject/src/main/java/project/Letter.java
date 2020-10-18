package project;

import akka.actor.typed.ActorRef;

public class Letter {
    public final ActorRef<DataNode.Command> destination;
    public final DataNode.Command message;

    public Letter ( ActorRef<DataNode.Command> destination,  DataNode.Command  message){
        this.destination = destination;
        this.message = message;
    }



}
