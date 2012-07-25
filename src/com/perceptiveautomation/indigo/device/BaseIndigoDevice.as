/**
 * Created with IntelliJ IDEA.
 * User: mreynolds
 * Date: 7/19/12
 * Time: 1:12 AM
 * To change this template use File | Settings | File Templates.
 */
package com.perceptiveautomation.indigo.device
{
    import com.perceptiveautomation.indigo.device.AbstractIndigoDevice;
    import com.perceptiveautomation.indigo.device.IIndigoDevice;

    public class BaseIndigoDevice extends AbstractIndigoDevice implements IIndigoDevice
    {
        public function BaseIndigoDevice(xmlNode:Object)
        {
            super(xmlNode);
        }
    }
}
