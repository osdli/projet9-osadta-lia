trigger OrderTrigger on Order (before update, after update) {
    if (Trigger.isBefore) {
        OrderTriggerHandler.beforeUpdate(Trigger.new);
    }
    
    if (Trigger.isAfter) {
        OrderTriggerHandler.afterUpdate(Trigger.new);
    }
}
