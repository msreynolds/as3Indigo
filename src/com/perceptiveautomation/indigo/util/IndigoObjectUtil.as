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
    import com.perceptiveautomation.indigo.device.DimmerDevice;
    import com.perceptiveautomation.indigo.device.IIndigoDevice;
    import com.perceptiveautomation.indigo.device.IOLincDevice;
    import com.perceptiveautomation.indigo.device.IRTransmitterDevice;
    import com.perceptiveautomation.indigo.device.IndigoDeviceFactory;
    import com.perceptiveautomation.indigo.device.OnOffDevice;
    import com.perceptiveautomation.indigo.device.ThermostatDevice;
    import com.perceptiveautomation.indigo.device.TimerDevice;
    import com.perceptiveautomation.indigo.schedule.IIndigoSchedule;
    import com.perceptiveautomation.indigo.schedule.IndigoSchedule;
    import com.perceptiveautomation.indigo.trigger.IIndigoTrigger;
    import com.perceptiveautomation.indigo.trigger.IndigoTrigger;
    import com.perceptiveautomation.indigo.variable.IIndigoVariable;
    import com.perceptiveautomation.indigo.variable.IndigoVariable;
    import com.perceptiveautomation.indigo.vo.AbstractIndigoDevice;

    import mx.collections.ArrayCollection;

    public class IndigoObjectUtil
    {
//        public function IndigoObjectUtil()
//        {
//        }

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

        public static function createDeviceList(packetData:XMLList):ArrayCollection
        {
            var len:int = packetData..Device.length();
            var tempDeviceCollection:ArrayCollection = new ArrayCollection();
            var tempDevice:IIndigoDevice;
            for(var i:int=0; i<len;i++)
            {
                tempDevice = createIndigoDevice(packetData..Device[i]);
                tempDeviceCollection.addItem(tempDevice);
            }

            return tempDeviceCollection;
        }

        public static function createActionGroupList(packetData:XMLList):ArrayCollection
        {
            var len:int = packetData..ActionGroup.length();
            var tempActionGroupCollection:ArrayCollection = new ArrayCollection();
            var tempActionGroup:IndigoActionGroup;
            for(var i:int=0; i<len;i++)
            {
                tempActionGroup = new IndigoActionGroup(packetData..ActionGroup[i]);
                //tempActionGroup.addEventListener("runNow", handleActionGroupRunNow, false, 0, true);
                tempActionGroupCollection.addItem(tempActionGroup);
            }
            return tempActionGroupCollection;
        }

        public static function createVariableList(packetData:XMLList):ArrayCollection
        {
            var len:int = packetData..Variable.length();
            var tempVariableCollection:ArrayCollection = new ArrayCollection();
            var tempVariable:IndigoVariable;
            for(var i:int=0; i<len;i++)
            {
                tempVariable = new IndigoVariable(packetData..Variable[i]);
                //tempVariable.addEventListener("valueChanged", handleVariableValueChange, false, 0, true);
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

        public static function replaceActionGroup(packetData:XMLList, collection:ArrayCollection):IIndigoActionGroup
        {
            var updatedIndigoActionGroup:IndigoActionGroup = new IndigoActionGroup(packetData.ActionGroup);
            var tempIndigoActionGroup:IIndigoActionGroup;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempIndigoActionGroup = collection.getItemAt(i) as IIndigoActionGroup;
                if (updatedIndigoActionGroup.name == tempIndigoActionGroup.name)
                {
                    // TODO:
                    //tempIndigoActionGroup.fill(updatedIndigoActionGroup);
                    return tempIndigoActionGroup;
                }
            }

            return null;
        }

        public static function replaceDevice(packetData:XMLList, collection:ArrayCollection):IIndigoDevice
        {
            var updatedIndigoDevice:BaseIndigoDevice = new BaseIndigoDevice(packetData.Device);
            var tempIndigoDevice:BaseIndigoDevice;
            var len:int = collection.length;
            for (var i:int = 0; i < len; i++)
            {
                tempIndigoDevice = collection.getItemAt(i) as BaseIndigoDevice;
                if (updatedIndigoDevice.name == tempIndigoDevice.name)
                {
                    tempIndigoDevice.fill(updatedIndigoDevice);
                    return tempIndigoDevice;
                }
            }

            return null;
        }

        public static function replaceSchedule(packetData:XMLList, collection:ArrayCollection):IIndigoSchedule
        {
            var updatedIndigoSchedule:IndigoSchedule = new IndigoSchedule(packetData.Variable);
            var tempIndigoSchedule:IIndigoSchedule;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempIndigoSchedule = collection.getItemAt(i) as IIndigoSchedule;
                if (updatedIndigoSchedule.name == tempIndigoSchedule.name)
                {
                    // TODO:
                    //tempIndigoSchedule.fill(updatedIndigoSchedule);
                    return tempIndigoSchedule;
                }
            }

            return null;
        }

        public static function replaceTrigger(packetData:XMLList, collection:ArrayCollection):IIndigoTrigger
        {
            var updatedIndigoTrigger:IndigoTrigger = new IndigoTrigger(packetData.Variable);
            var tempIndigoTrigger:IIndigoTrigger;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempIndigoTrigger = collection.getItemAt(i) as IIndigoTrigger;
                if (updatedIndigoTrigger.name == tempIndigoTrigger.name)
                {
                    // TODO:
                    //tempIndigoTrigger.fill(updatedIndigoTrigger);
                    return tempIndigoTrigger;
                }
            }

            return null;
        }

        public static function replaceVariable(packetData:XMLList, collection:ArrayCollection):IIndigoVariable
        {
            var updatedIndigoVariable:IndigoVariable = new IndigoVariable(packetData.Variable);
            var tempIndigoVariable:IndigoVariable;
            var len:int = collection?collection.length:0;
            for (var i:int = 0; i < len; i++)
            {
                tempIndigoVariable = collection.getItemAt(i) as IndigoVariable;
                if (updatedIndigoVariable.name == tempIndigoVariable.name)
                {
                    tempIndigoVariable.value = updatedIndigoVariable.value;
                    return tempIndigoVariable;
                }
            }

            return null;
        }

    }
}
