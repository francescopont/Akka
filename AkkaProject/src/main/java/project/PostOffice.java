package project;

import java.util.LinkedList;
import java.util.List;

public class PostOffice {
    private  LinkedList<DataNode.Command> incomingCommands = new LinkedList<>();
    private final LinkedList<Letter> outgoingLetters = new LinkedList<>();
    private int stampsAmount;

    public PostOffice(int stampsAmount){
        this.stampsAmount = stampsAmount;
    }

    public void send(Letter letter){
        if (stampsAmount > 0){
            letter.destination.tell(letter.message);
            stampsAmount--;
        }
        else{
            outgoingLetters.addLast(letter);
        }
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
        //trash expired stamps, if any
        stampsAmount = amount;
        while ( outgoingLetters.size() > 0 && stampsAmount > 0){
            Letter letter = outgoingLetters.pollFirst();
            letter.destination.tell(letter.message);
            stampsAmount--;
        }
    }



}
