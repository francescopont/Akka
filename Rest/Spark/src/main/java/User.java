import java.util.Collection;
import java.util.HashMap;

class User {

    private Integer id;
    private String username;
    private String password;
    private HashMap<String, Image> images = new HashMap<>();

    public User(int id, String username, String password) {
        super();
        this.id = id;
        this.username = username;
        this.password= password;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void addImage(Image image){
        this.images.put(image.getKey(),image);
    }

    public void deleteImage(String key){
        this.images.remove(key);
    }

    public Collection<Image> getAllImages(){
        return this.images.values();
    }
}
