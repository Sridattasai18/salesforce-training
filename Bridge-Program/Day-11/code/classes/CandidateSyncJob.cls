public class CandidateSyncJob implements Queueable, Database.AllowsCallouts {
    
    private List<Id> applicationIds;
    
    public CandidateSyncJob(List<Id> applicationIds) {
        this.applicationIds = applicationIds;
    }
    
    public void execute(QueueableContext context) {
        ExternalPlacementService.syncSelectedCandidates(applicationIds);
    }
}
