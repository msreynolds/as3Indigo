/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/24/12
 * Time: 8:03 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.util {
import mx.collections.XMLListCollection;

import spark.collections.Sort;
import spark.collections.SortField;

public class SortUtil {
    public static function sortData(list:XMLListCollection, field:String):XMLListCollection
    {
        var sort:Sort;

        sort = new Sort();
        sort.fields = [new SortField(field, true)];
        list.sort = sort;
        list.refresh();
        return list;
    }
}
}
