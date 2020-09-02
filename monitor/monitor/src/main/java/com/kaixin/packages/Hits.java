/**
  * Copyright 2020 bejson.com 
  */
package com.kaixin.packages;
import java.util.List;

/**
 * Auto-generated: 2020-09-02 12:37:52
 *
 * @author bejson.com (i@bejson.com)
 * @website http://www.bejson.com/java2pojo/
 */
public class Hits {

    private Total total;
    private String max_score;
    private List<String> hits;
    public void setTotal(Total total) {
         this.total = total;
     }
     public Total getTotal() {
         return total;
     }

    public void setMax_score(String max_score) {
         this.max_score = max_score;
     }
     public String getMax_score() {
         return max_score;
     }

    public void setHits(List<String> hits) {
         this.hits = hits;
     }
     public List<String> getHits() {
         return hits;
     }

}