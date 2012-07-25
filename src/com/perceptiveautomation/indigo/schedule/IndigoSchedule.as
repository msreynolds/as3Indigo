/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/20/12
 * Time: 12:19 AM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.schedule {
import com.perceptiveautomation.indigo.schedule.IIndigoSchedule;

import flash.events.Event;

import flash.events.EventDispatcher;

public class IndigoSchedule extends EventDispatcher implements IIndigoSchedule
{

    private var _name:String;
    private var _description:String;
    private var _folder:String;
    private var _nextExecuteDate:String;

    public function IndigoSchedule(xmlNode:Object)
    {
        this._name = xmlNode.Name;
        this._description = xmlNode.Description;
        this._folder = xmlNode.Folder;
        this._nextExecuteDate = xmlNode.NextExecute;
    }

    [Bindable(event='nameChanged')]
    public function get name():String
    {
        return this._name;
    }

    public function set name(value:String):void
    {
        if (this._name != value)
        {
            this._name = value;
            dispatchEvent(new Event('nameChanged'));
        }
    }

    [Bindable(event='descriptionChanged')]
    public function get description():String
    {
        return this._description;
    }

    public function set description(value:String):void
    {
        if (this._description != value)
        {
            this._description = value;
            dispatchEvent(new Event('descriptionChanged'));
        }
    }

    [Bindable(event="folderChanged")]
    public function get folder():String {
        return _folder;
    }

    public function set folder(value:String):void {
        if (_folder == value) return;
        _folder = value;
        dispatchEvent(new Event("folderChanged"));
    }

    [Bindable(event="nextExecuteDateChanged")]
    public function get nextExecuteDate():String {
        return _nextExecuteDate;
    }

    public function set nextExecuteDate(value:String):void {
        if (_nextExecuteDate == value) return;
        _nextExecuteDate = value;
        dispatchEvent(new Event("nextExecuteDateChanged"));
    }

    public function fill(value:IIndigoSchedule):void
    {
        this.name = value.name;
        this.description = value.description;
        this.folder = value.folder;
        this.nextExecuteDate = value.nextExecuteDate;
    }
}
}
