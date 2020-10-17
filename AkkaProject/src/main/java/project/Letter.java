package project;

import akka.actor.typed.ActorRef;

public class Letter {
    private final ActorRef<DataNode.Command> destination;
    private final DataNode.Command message;

    public Letter ( ActorRef<DataNode.Command> destination,  DataNode.Command  message){
        this.destination = destination;
        this.message = message;
    }


}
