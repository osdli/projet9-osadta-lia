public class TestDataFactory {

    // Créer des comptes de test
    public static List<Account> createAccounts(Integer numAccounts) {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < numAccounts; i++) {
            accounts.add(new Account(Name = 'Test Account ' + i));
        }
        insert accounts;
        return accounts; 
    }

    // Créer des contrats de test pour des comptes spécifiques
    public static List<Contract> createContractsForAccounts(List<Account> accounts) {
        List<Contract> contracts = new List<Contract>();
        Date today = System.today();
        Integer contractTermMonths = 12; 

        for (Account acc : accounts) {
            Contract ctr = new Contract(
                AccountId = acc.Id, 
                StartDate = today, 
                ContractTerm = contractTermMonths, 
                Status = 'Draft'
            );
            contracts.add(ctr);
        }
        insert contracts;

        // Activer les contrats après leur création
        for (Contract ctr : contracts) {
            ctr.Status = 'Activated'; 
        }
        update contracts;

        return contracts;
    }

    // Créer des OrderItems pour les commandes
    public static void createOrderItemsForOrders(List<Order> orders, Id priceBookEntryId, Decimal unitPrice, Integer quantity) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for(Order order : orders) {
            OrderItem orderItem = new OrderItem(
                OrderId = order.Id,
                PricebookEntryId = priceBookEntryId,
                Quantity = quantity,
                UnitPrice = unitPrice
            );
            orderItems.add(orderItem);
        }
        
        try {
            insert orderItems; // Insère tous les OrderItem en une seule opération DML
            System.debug('OrderItems inserted successfully');
        } catch (Exception e) {
            System.debug('Error inserting OrderItems: ' + e.getMessage());
            // Gérer l'erreur comme il convient, par exemple, en loggant ou en lançant une exception customisée
        }
    }

    // Créer un nombre spécifié de commandes pour des comptes
    public static List<Order> createOrdersForAccounts(List<Account> accounts, String initialStatus, Integer numOrdersPerAccount, Id priceBookEntryId, Decimal unitPrice, Integer quantityPerOrder) {
        List<Order> orders = new List<Order>();
        List<Contract> contracts = createContractsForAccounts(accounts);
    
        // Avant de créer les commandes, récupérer l'ID du livre de prix associé à l'entrée du livre de prix
        PriceBookEntry pbe = [SELECT Id, Pricebook2Id FROM PriceBookEntry WHERE Id = :priceBookEntryId LIMIT 1];
        Id priceBookId = pbe.Pricebook2Id;
    
        // Création des commandes avec le statut initial et association du livre de prix
        for(Account acc : accounts) {
            for(Integer i = 0; i < numOrdersPerAccount; i++) {
                Order newOrder = new Order(
                    AccountId = acc.Id, 
                    Status = initialStatus, 
                    EffectiveDate = System.today(), 
                    Pricebook2Id = priceBookId 
                );
                orders.add(newOrder);
            }
        }
        insert orders;
    
        // Création et insertion des OrderItems pour chaque commande
        createOrderItemsForOrders(orders, priceBookEntryId, unitPrice, quantityPerOrder);

        return orders;
    }

    // Méthode pour créer un produit de test et son entrée dans le livre de prix
    public static Id createTestProductAndPriceBookEntry() {
        // Créer et insérez un produit
        Product2 prod = new Product2(Name = 'GenWatt Diesel 10kW', ProductCode = 'GC1020');
        insert prod;

        // Récupérer l'ID du livre de prix standard
        Id standardPBId = Test.getStandardPricebookId();

        // Créer et insérer une entrée de livre de prix pour le produit
        PriceBookEntry standardPBE = new PriceBookEntry(
            Product2Id = prod.Id,
            PriceBook2Id = standardPBId,
            UnitPrice = 5000.00,
            IsActive = true
        );
        insert standardPBE;
        
        return standardPBE.Id;
    }
}
