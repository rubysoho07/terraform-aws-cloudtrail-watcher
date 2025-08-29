# This is temporary code to create a zip file for the lambda function
from cloudtrail_watcher.event_handler import handler

def watcher_handler(event, context):
    return handler(event, context)