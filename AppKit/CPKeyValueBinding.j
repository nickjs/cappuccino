/*
 * CPKeyValueBinding.j
 * AppKit
 *
 * Created by Ross Boucher.
 * Extended by Nicholas Small.
 * Copyright 2009, 280 North, Inc.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 */

@import <Foundation/CPObject.j>


@implementation CPKeyValueBinding : CPObject
{
    id                      source              @accessors(readonly);
    CPString                binding             @accessors(readonly);
    
    id                      destination         @accessors(readonly);
    CPString                keyPath             @accessors(readonly);
    
    CPValueTransformer      valueTransformer    @accessors;
    CPDictionary            options             @accessors;
}

- (id)initWithSource:(id)aSource binding:(CPString)aBinding destination:(id)aDestination keyPath:(CPString)aKeyPath
{
    self = [super init];
    
    if (self)
    {
        source = aSource;
        binding = [aBinding copy];
        
        destination = aDestination;
        keyPath = [aKeyPath copy];
        
        [destination addObserver:self forKeyPath:keyPath options:CPKeyValueObservingOptionNew context:binding];
    }
    
    return self;
}

- (void)unbind
{
    [destination removeObserver:self forKeyPath:keyPath];
}

- (void)setValueOfDestinationFromBinding
{
    var value = [source valueForKeyPath:binding];
    
    value = [self reverseTransformValue:value];
    
    [destination setValue:value forKeyPath:keyPath];
}

- (void)setValueOfBindingFromDestination
{
    var value = [destination valueForKeyPath:keyPath];
    
    value = [self transformValue:value];
    
    [source setValue:value forKeyPath:binding];
}

- (void)observeValueForKeyPath:(CPString)aKeyPath ofObject:(id)anObject change:(CPDictionary)aDictionary context:(id)aContext
{
    if (!aDictionary)
        return;
    
    if (anObject !== destination)
        return;
    
    if (!aContext || aContext !== binding)
        return;
    
    [self setValueOfBindingFromDestination];
}

- (void)transformValue:(id)aValue
{
    return aValue;
}

- (void)reverseTransformValue:(id)aValue
{
    return aValue;
}

@end

@implementation CPObject (CPKeyValueBinding)

- (void)bind:(CPString)aBinding toObject:(id)aDestination withKeyPath:(CPString)aKeyPath options:(CPDictionary)aDictionary
{
    if (!aBinding || !aDestination || !aKeyPath)
        return;
    
    var bindingName = [self _bindingNameForBinding:aBinding],
        binding = [self bindingObjectForBinding:aBinding];
    
    if (binding)
        [self unbind:aBinding];
    
    var binding = [[CPKeyValueBinding alloc] initWithSource:self binding:aBinding destination:aDestination keyPath:aKeyPath];
    self[bindingName] = binding;
}

- (void)unbind:(CPString)aBinding
{
    if (!aBinding)
        return;
    
    var binding = [self bindingObjectForBinding:aBinding];
    
    if (binding)
    {
        [binding unbind];
        delete self[[self _bindingNameForBinding:aBinding]];
    }
}

- (CPDictionary)infoForBinding:(CPString)aBinding
{
    var binding = [self bindingObjectForBinding:aBinding],
        dict = [CPDictionary dictionary];
    
    return dict;
}

- (CPKeyValueBinding)bindingObjectForBinding:(CPString)aBinding
{
    return self[[self _bindingNameForBinding:aBinding]];
}

- (CPString)_bindingNameForBinding:(CPString)aBinding
{
    aBinding = [self _replacementKeyPathForBinding:aBinding];
    return [@"$KVB_", aBinding].join(@"");
}

- (void)_replacementKeyPathForBinding:(CPString)aKeyPath
{
    if ([aKeyPath isEqual:@"value"])
        aKeyPath = @"objectValue";
    
    return aKeyPath;
}

+ (void)exposeBinding:(CPString)aBinding
{
    
}

- (CPArray)exposedBindings
{
    return [];
}

@end

CPObservedObjectKey     = @"CPObservedObjectKey";
CPObservedKeyPathKey    = @"CPObservedKeyPathKey";
CPOptionsKey            = @"CPOptionsKey";

// special markers
CPMultipleValuesMarker  = @"CPMultipleValuesMarker";
CPNoSelectionMarker     = @"CPNoSelectionMarker";
CPNotApplicableMarker   = @"CPNotApplicableMarker";

// Binding name constants
CPAlignmentBinding      = @"CPAlignmentBinding";
CPEditableBinding       = @"CPEditableBinding";
CPEnabledBinding        = @"CPEnabledBinding";
CPFontBinding           = @"CPFontBinding";
CPHiddenBinding         = @"CPHiddenBinding";
CPSelectedIndexBinding  = @"CPSelectedIndexBinding";
CPTextColorBinding      = @"CPTextColorBinding";
CPToolTipBinding        = @"CPToolTipBinding";
CPValueBinding          = @"value";

//Binding options constants
CPAllowsEditingMultipleValuesSelectionBindingOption = @"CPAllowsEditingMultipleValuesSelectionBindingOption";
CPAllowsNullArgumentBindingOption                   = @"CPAllowsNullArgumentBindingOption";
CPConditionallySetsEditableBindingOption            = @"CPConditionallySetsEditableBindingOption";
CPConditionallySetsEnabledBindingOption             = @"CPConditionallySetsEnabledBindingOption";
CPConditionallySetsHiddenBindingOption              = @"CPConditionallySetsHiddenBindingOption";
CPContinuouslyUpdatesValueBindingOption             = @"CPContinuouslyUpdatesValueBindingOption";
CPCreatesSortDescriptorBindingOption                = @"CPCreatesSortDescriptorBindingOption";
CPDeletesObjectsOnRemoveBindingsOption              = @"CPDeletesObjectsOnRemoveBindingsOption";
CPDisplayNameBindingOption                          = @"CPDisplayNameBindingOption";
CPDisplayPatternBindingOption                       = @"CPDisplayPatternBindingOption";
CPHandlesContentAsCompoundValueBindingOption        = @"CPHandlesContentAsCompoundValueBindingOption";
CPInsertsNullPlaceholderBindingOption               = @"CPInsertsNullPlaceholderBindingOption";
CPInvokesSeparatelyWithArrayObjectsBindingOption    = @"CPInvokesSeparatelyWithArrayObjectsBindingOption";
CPMultipleValuesPlaceholderBindingOption            = @"CPMultipleValuesPlaceholderBindingOption";
CPNoSelectionPlaceholderBindingOption               = @"CPNoSelectionPlaceholderBindingOption";
CPNotApplicablePlaceholderBindingOption             = @"CPNotApplicablePlaceholderBindingOption";
CPNullPlaceholderBindingOption                      = @"CPNullPlaceholderBindingOption";
CPPredicateFormatBindingOption                      = @"CPPredicateFormatBindingOption";
CPRaisesForNotApplicableKeysBindingOption           = @"CPRaisesForNotApplicableKeysBindingOption";
CPSelectorNameBindingOption                         = @"CPSelectorNameBindingOption";
CPSelectsAllWhenSettingContentBindingOption         = @"CPSelectsAllWhenSettingContentBindingOption";
CPValidatesImmediatelyBindingOption                 = @"CPValidatesImmediatelyBindingOption";
CPValueTransformerNameBindingOption                 = @"CPValueTransformerNameBindingOption";
CPValueTransformerBindingOption                     = @"CPValueTransformerBindingOption";
