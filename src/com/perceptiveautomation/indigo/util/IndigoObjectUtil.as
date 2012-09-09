/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 8/26/12
 * Time: 8:08 PM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.util
{
    import com.perceptiveautomation.indigo.actiongroup.IIndigoActionGroup;
    import com.perceptiveautomation.indigo.actiongroup.IndigoActionGroup;
    import com.perceptiveautomation.indigo.device.BaseIndigoDevice;
    import com.perceptiveautomation.indigo.device.IIndigoDevice;
    import com.perceptiveautomation.indigo.device.IndigoDeviceFactory;
    import com.perceptiveautomation.indigo.schedule.IIndigoSchedule;
    import com.perceptiveautomation.indigo.schedule.IndigoSchedule;
    import com.perceptiveautomation.indigo.trigger.IIndigoTrigger;
    import com.perceptiveautomation.indigo.trigger.IndigoTrigger;
    import com.perceptiveautomation.indigo.variable.IIndigoVariable;
    import com.perceptiveautomation.indigo.variable.IndigoVariable;

    import mx.collections.ArrayCollection;
    import mx.collections.IList;

    public class IndigoObjectUtil
    {

        // CREATE
        public static function createIndigoActionGroup(xmlNode:XML):IIndigoActionGroup
        {
            return new IndigoActionGroup(xmlNode);
        }

        public static function createIndigoDevice(xmlNode:XML):IIndigoDevice
        {
            return IndigoDeviceFactory.createIndigoDevice(xmlNode);
        }

        public static function createIndigoSchedule(xmlNode:XML):IIndigoSchedule
        {
            return new IndigoSchedule(xmlNode);
        }

        public static function createIndigoTrigger(xmlNode:XML):IIndigoTrigger
        {
            return new IndigoTrigger(xmlNode);
        }

        public static function createIndigoVariable(xmlNode:XML):IIndigoVariable
        {
            return new IndigoVariable(xmlNode);
        }


        // CREATE LIST
        public static function createDeviceList(xmlData:XMLList):ArrayCollection
        {
            return IndigoDeviceFactory.createIndigoDeviceList(xmlData) as ArrayCollection;
        }

        public static function createActionGroupList(xmlData:XMLList):ArrayCollection
        {
            var len:int = xmlData..ActionGroup.length();
            var tempActionGroupCollection:ArrayCollection = new ArrayCollection();
            var tempActionGroup:IndigoActionGroup;
            for(var i:int=0; i<len;i++)
            {
                tempActionGroup = new IndigoActionGroup(xmlData..ActionGroup[i]);
                tempActionGroupCollection.addItem(tempActionGroup);
            }
            return tempActionGroupCollection;
            //return IndigoActionGroupFactory.createActionGroupList(xmlData);
        }

        public static function createVariableList(packetData:XMLList):ArrayCollection
        {
            var len:int = packetData..Variable.length();
            var tempVariableCollection:ArrayCollection = new ArrayCollection();
            var tempVariable:IndigoVariable;
            for(var i:int=0; i<len;i++)
            {
                tempVariable = new IndigoVariable(packetData..Variable[i]);
                tempVariableCollection.addItem(tempVariable);
            }
            return tempVariableCollection;
        }

        public static function createTriggerList(packetData:XMLList):ArrayCollection
        {
            var len:int = packetData..Trigger.length();
            var tempTriggerCollection:ArrayCollection = new ArrayCollection();
            var tempTrigger:IndigoTrigger;
            for(var i:int=0; i<len;i++)
            {
                tempTrigger = new IndigoTrigger(packetData..Trigger[i]);
                tempTriggerCollection.addItem(tempTrigger);
            }
            return tempTriggerCollection;
        }

        public static function createScheduleList(packetData:XMLList):ArrayCollection
        {
            var len:int = packetData..TDTrigger.length();
            var tempScheduleCollection:ArrayCollection = new ArrayCollection();
            var tempSchedule:IndigoSchedule;
            for(var i:int=0; i<len;i++)
            {
                tempSchedule = new IndigoSchedule(packetData..TDTrigger[i]);
                tempScheduleCollection.addItem(tempSchedule);
            }
            return tempScheduleCollection;
        }


        // GET
        public static function getActionGroup(actionGroup:IIndigoActionGroup, collection:ArrayCollection):IIndigoActionGroup
        {
            var tempActionGroup:IIndigoActionGroup;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempActionGroup = collection.getItemAt(i) as IIndigoActionGroup;
                if (actionGroup.id == tempActionGroup.id)
                {
                    return tempActionGroup;
                }
            }

            return null;
        }

        public static function getDevice(updatedIndigoDevice:IIndigoDevice, collection:ArrayCollection):IIndigoDevice
        {
            var tempDevice:IIndigoDevice;
            var len:int = collection.length;
            for (var i:int = 0; i < len; i++)
            {
                tempDevice = collection.getItemAt(i) as BaseIndigoDevice;
                if (updatedIndigoDevice.name == tempDevice.name)
                {
                    return tempDevice;
                }
            }

            return null;
        }

        public static function getSchedule(schedule:IIndigoSchedule, collection:ArrayCollection):IIndigoSchedule
        {
            var tempSchedule:IIndigoSchedule;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempSchedule = collection.getItemAt(i) as IIndigoSchedule;
                if (schedule.id == tempSchedule.id)
                {
                    return tempSchedule;
                }
            }

            return null;
        }

        public static function getTrigger(trigger:IIndigoTrigger, collection:ArrayCollection):IIndigoTrigger
        {
            var tempTrigger:IIndigoTrigger;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempTrigger = collection.getItemAt(i) as IIndigoTrigger;
                if (trigger.id == tempTrigger.id)
                {
                    return tempTrigger;
                }
            }

            return null;
        }

        public static function getVariable(variable:IIndigoVariable, collection:ArrayCollection):IIndigoVariable
        {
            var tempVariable:IIndigoVariable;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempVariable = collection.getItemAt(i) as IndigoVariable;
                if (variable.id == tempVariable.id)
                {
                    return tempVariable;
                }
            }

            return null;
        }


        // ADD
        public static function addActionGroup(actionGroup:IIndigoActionGroup, collection:ArrayCollection):IIndigoActionGroup
        {
            collection.addItem(actionGroup)
            return actionGroup;
        }

        public static function addDevice(device:IIndigoDevice, collection:ArrayCollection):IIndigoDevice
        {
            collection.addItem(device);
            return device;
        }

        public static function addSchedule(schedule:IIndigoSchedule, collection:ArrayCollection):IIndigoSchedule
        {
            collection.addItem(schedule);
            return schedule;
        }

        public static function addTrigger(trigger:IIndigoTrigger, collection:ArrayCollection):IIndigoTrigger
        {
            collection.addItem(trigger);
            return trigger;
        }

        public static function addVariable(variable:IIndigoVariable, collection:ArrayCollection):IIndigoVariable
        {
            collection.addItem(variable);
            return variable;
        }


        // REPLACE
        public static function replaceActionGroup(actionGroup:IIndigoActionGroup, collection:ArrayCollection):IIndigoActionGroup
        {
            var tempActionGroup:IIndigoActionGroup;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempActionGroup = collection.getItemAt(i) as IIndigoActionGroup;
                if (actionGroup.id == tempActionGroup.id)
                {
                    // TODO: write fill method
                    //tempActionGroup.fill(actionGroup);
                    return tempActionGroup;
                }
            }

            return null;
        }

        public static function replaceDevice(device:IIndigoDevice, collection:ArrayCollection):IIndigoDevice
        {
            var tempDevice:IIndigoDevice;
            var len:int = collection.length;
            for (var i:int = 0; i < len; i++)
            {
                tempDevice = collection.getItemAt(i) as BaseIndigoDevice;
                if (device.id == tempDevice.id)
                {
                    tempDevice.fill(device);
                    return tempDevice;
                }
            }

            return null;
        }

        public static function replaceSchedule(schedule:IIndigoSchedule, collection:ArrayCollection):IIndigoSchedule
        {
            var tempSchedule:IIndigoSchedule;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempSchedule = collection.getItemAt(i) as IIndigoSchedule;
                if (schedule.id == tempSchedule.id)
                {
                    // TODO: write fill method
                    //tempIndigoSchedule.fill(updatedIndigoSchedule);
                    return tempSchedule;
                }
            }

            return null;
        }

        public static function replaceTrigger(trigger:IIndigoTrigger, collection:ArrayCollection):IIndigoTrigger
        {
            var tempIndigoTrigger:IIndigoTrigger;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempIndigoTrigger = collection.getItemAt(i) as IIndigoTrigger;
                if (trigger.name == tempIndigoTrigger.name)
                {
                    // TODO: write fill method
                    //tempIndigoTrigger.fill(updatedIndigoTrigger);
                    return tempIndigoTrigger;
                }
            }

            return null;
        }

        public static function replaceVariable(variable:IIndigoVariable, collection:ArrayCollection):IIndigoVariable
        {
            var tempVariable:IndigoVariable;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempVariable = collection.getItemAt(i) as IndigoVariable;
                if (variable.id == tempVariable.id)
                {
                    // TODO: write fill method
                    //tempVariable.fill(variable);
                    tempVariable.value = variable.value;
                    return tempVariable;
                }
            }

            return null;
        }


        // ADD OR REPLACE
        public static function addOrReplaceActionGroup(actionGroup:IIndigoActionGroup, collection:ArrayCollection):IIndigoActionGroup
        {
            var tempActionGroup:IIndigoActionGroup = replaceActionGroup(actionGroup, collection);
            if (tempActionGroup == null)
            {
                tempActionGroup = addActionGroup(actionGroup, collection);
            }

            return tempActionGroup;
        }

        public static function addOrReplaceDevice(device:IIndigoDevice, collection:ArrayCollection):IIndigoDevice
        {
            var tempDevice:IIndigoDevice = replaceDevice(device, collection);
            if (tempDevice == null)
            {
                tempDevice = addDevice(device, collection);
            }

            return tempDevice;
        }

        public static function addOrReplaceSchedule(schedule:IIndigoSchedule, collection:ArrayCollection):IIndigoSchedule
        {
            var tempSchedule:IIndigoSchedule = replaceSchedule(schedule, collection);
            if (tempSchedule == null)
            {
                tempSchedule = addSchedule(schedule, collection);
            }

            return tempSchedule;
        }

        public static function addOrReplaceTrigger(trigger:IIndigoTrigger, collection:ArrayCollection):IIndigoTrigger
        {
            var tempTrigger:IIndigoTrigger = replaceTrigger(trigger, collection);
            if (tempTrigger == null)
            {
                tempTrigger = addTrigger(trigger, collection);
            }

            return tempTrigger;
        }

        public static function addOrReplaceVariable(variable:IIndigoVariable, collection:ArrayCollection):IIndigoVariable
        {
            var tempVariable:IIndigoVariable = replaceVariable(variable, collection);
            if (tempVariable == null)
            {
                tempVariable = addVariable(variable, collection);
            }

            return tempVariable;
        }

    }
}
