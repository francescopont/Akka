package project;

import java.util.LinkedList;
import java.util.List;

public class PostOffice {
    private  LinkedList<DataNode.Command> incomingCommands = new LinkedList<>();
    private final LinkedList<Letter> outgoingLetters = new LinkedList<>();

    public void send(Letter letter){
        outgoingLetters.addLast(letter);
    }

    public void archive(DataNode.Command command){
        incomingCommands.addLast(command);
    }

    public List<DataNode.Command> getCommands(){
        LinkedList<DataNode.Command> list = new LinkedList<>(this.incomingCommands);
        this.incomingCommands = new LinkedList<>();
        return list;
    }

    public void addStamps(int amount){
        while ( amount > 0){
            Letter letter = outgoingLetters.pollFirst();
            if (letter != null){
                letter.destination.tell(letter.message);
            }
            amount--;
        }
    }



}
